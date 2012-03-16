<?php

error_reporting(E_ALL);

class dummy
{
    var $id;
    var $username;
    var $password;
    var $target;
    // date the bot commented last
    var $lastcomment;
    // date of last comment we posted
    var $lastupdated;
    var $modhash;
    var $cookie;

    // returns number of seconds before rate limit is lifted or FALSE
    function ratelimit()
    {
        if(!isset($this->lastcomment) || $this->lastcomment == null)
        {
            return false;
        }
        $limit = 60 * 11; // 11 mins
        $remaining = $limit - (time() - $this->lastcomment);
        if($remaining <= 0)
        {
            return false;
        }
        return $remaining;
    }

    function save($db)
    {
        $stmt = $db->prepare('update dummy set lastupdated=:lastupdated, lastcomment=:lastcomment, modhash=:modhash, cookie=:cookie where id=:id');
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':lastcomment', $this->lastcomment);
        $stmt->bindParam(':lastupdated', $this->lastupdated);
        $stmt->bindParam(':modhash', $this->modhash);
        $stmt->bindParam(':cookie', $this->cookie);
        $stmt->execute();
    }

    function login($db)
    {
        if(strlen($this->modhash) == 0)
        {
            var_dump($this->username . ' is logging in...');
            $request = new loginrequest($this);
            $data = $request->execute();
            if($data === false)
            {
                var_dump('unable to login');
                return false;
            }
            $this->modhash = $data->json->data->modhash;
            $this->cookie = $data->json->data->cookie;
            $this->save($db);
        }
        return true;
    }

    function cookies()
    {
        return 'reddit_session=' . $this->cookie;
    }

    function loadcomments()
    {
        $cf = new commentfetcher();
        $comments = $cf->getcomments($this->target, $this->lastupdated, $this->cookies());
        $comments = array_reverse($comments);
        return $comments;
    }
}

class apicall
{
    function postrequest($url, $args, $cookies)
    {
        return $this->request($url, $args, $cookies, array(
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $args));
    }

    function getrequest($url, $cookies)
    {
        return $this->request($url, array(), $cookies, array());
    }

    function request($url, $args, $cookies, $curlopts)
    {
        if(!isset($cookies))
        {
            $cookies = '';
        }
        $request = array($url, $args, $cookies, $curlopts);
        var_dump('performing request... ' . json_encode($request));
        sleep(6);
        $ch = curl_init();
        curl_setopt_array($ch, $curlopts);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
        curl_setopt($ch, CURLOPT_COOKIESESSION, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_COOKIE, $cookies);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_USERAGENT, 'reddit saver_bot');
        $result = curl_exec($ch);
        curl_close($ch);
        if($result !== false)
        {
            $result = json_decode($result);
        }
        return $result;
    }
}

class loginrequest extends apicall
{
    var $dummy;

    function __construct($dummy)
    {
        $this->dummy = $dummy;
    }

    function execute()
    {
        return parent::postrequest('https://ssl.reddit.com/api/login/' . $this->dummy->username, array(
            'user'     => $this->dummy->username,
            'passwd'   => $this->dummy->password,
            'api_type' => 'json'
        ), null);
    }
}

class getusercommentsrequest extends apicall
{
    var $user;
    var $after;
    var $cookies;

    function __construct($user, $after, $cookies)
    {
        $this->user = $user;
        $this->after = $after;
        $this->cookies = $cookies;
    }

    function execute()
    {
        $url = 'http://www.reddit.com/user/' . $this->user . '.json?after=' . $this->after;
        return parent::getrequest($url, $this->cookies);
    }
}

class commentrequest extends apicall
{
    var $parent;
    var $text;
    var $userhash;
    var $cookies;

    function __construct($parent, $text, $userhash, $cookies)
    {
        $this->parent = $parent;
        $this->text = $text;
        $this->userhash = $userhash;
        $this->cookies = $cookies;
    }

    function haserrors($result)
    {
        foreach($result as $item)
        {
            if(is_object($item))
            {
                return false;
            }
            if(is_array($item))
            {
                if(($err = $this->haserrors($item)) !== false)
                {
                    return $err;
                }
                continue;
            }
            if(strpos($item, 'error') !== false)
            {
                return $item;
            }
        }
        return false;
    }

    function execute()
    {
        return parent::postrequest('http://www.reddit.com/api/comment', array(
            'parent' => $this->parent,
            'text'   => $this->text,
            'uh'     => $this->userhash
        ), $this->cookies);
    }
}

class commentfetcher
{
    function getcomments($user, $since, $cookies, $after = '')
    {
        sleep(1);
        if(!isset($since))
        {
            $since = 0;
        }
        $request = new getusercommentsrequest($user, $after, $cookies);
        $data = $request->execute();
        if($data === false)
        {
            return false;
        }
        $result = array();
        foreach($data->data->children as $thing)
        {
            if($thing->data->created_utc <= $since)
            {
                return $result;
            }
            if($thing->kind != 't1')
            {
                continue;
            }
            if(strlen($thing->data->body) == 0)
            {
                continue;
            }
            //// only used during the creation of the initial comments queue
            //if($thing->data->ups < 10)
            //{
            //  continue;
            //}
            $result[] = $thing;
        }
        $after = isset($data->data->after) ? $data->data->after : '';
        if(strlen($after) > 0)
        {
            $result = array_merge($result, $this->getcomments($user, $since, $cookies, $after));
        }
        return $result;
    }
}

class app
{
    function start()
    {
        $db = new PDO('sqlite:' . dirname(__FILE__) . '/savers.db');
        $stmt = $db->query('select * from dummy');
        $dummies = $stmt->fetchAll(PDO::FETCH_CLASS, 'dummy');
        $cf = new commentfetcher();
        foreach($dummies as $dummy)
        {
            if(!$dummy->login($db))
            {
                continue;
            }
            $comments = $dummy->loadcomments();
            var_dump(count($comments) . ' comment' . (count($comments) != 1 ? 's' : '') . ' pending for ' . $dummy->target);
            foreach($comments as $i => $comment)
            {
                if($dummy->ratelimit() !== false)
                {
                    var_dump($dummy->username . ' is taking a break (rate limit)');
                    break;
                }

                $limit = 60 * 60 * 16; // 16 hours
                if($limit - (time() - $comment->data->created_utc) > 0)
                {
                    var_dump($dummy->username . ' comment was posted less than 16 hours ago, coming back later');
                    continue;
                }

                if($comment->data->ups < 10)
                {
                    var_dump($dummy->username . ' comment had less than 10 upvotes...ignoring');
                    $dummy->lastupdated = $comment->data->created_utc;
                    $dummy->save($db);
                    continue;
                }

                $fullname = $comment->data->name;
                $text = $comment->data->body;

                $arr = explode("\n", $text);
                $text = '>' . implode("\n>", $arr);

                var_dump($dummy->username . ' replying to ' . $fullname . ' @ ' . date('r'));

                $request = new commentrequest($fullname, $text, $dummy->modhash, $dummy->cookies());
                $result = $request->execute();

                if($result === false || ($err = $request->haserrors($result)) !== false)
                {
                    // don't want to keep trying to post comments if we are getting RATELIMIT error responses
                    $dummy->lastcomment = time();
                    $dummy->save($db);
                    var_dump($err, json_encode($result));
                    break;
                }

                $dummy->lastcomment = time();
                $dummy->lastupdated = $comment->data->created_utc;
                $dummy->save($db);

                unset($comments[$i]);
            }
        }
    }

    function info()
    {
        $db = new PDO('sqlite:' . dirname(__FILE__) . '/savers.db');
        $stmt = $db->query('select * from dummy');
        $dummies = $stmt->fetchAll(PDO::FETCH_CLASS, 'dummy');
        foreach($dummies as $dummy)
        {
            var_dump($dummy);
            var_dump('date of last comment posted: ' . $this->ago($dummy->lastupdated) . ' ago');
            var_dump('last comment posted ' . $this->ago($dummy->lastcomment) . ' ago');
            var_dump('rate limited? ' . ($dummy->ratelimit() !== false ? 'Yes' : 'No'));
            if($dummy->ratelimit() !== false)
            {
                var_dump('minutes until rate limit ends: ' . ($dummy->ratelimit() / 60));
            }
        }
    }

    function logout()
    {
        $db = new PDO('sqlite:' . dirname(__FILE__) . '/savers.db');
        $stmt = $db->query('update dummy set modhash=null, cookie=null');
        $stmt->execute();
    }

    // Source: http://css-tricks.com/snippets/php/time-ago-function/
    function ago($time)
    {
        $periods = array("second", "minute", "hour", "day", "week", "month", "year", "decade");
        $lengths = array("60","60","24","7","4.35","12","10");
        $now = time();
        $difference = $now - $time;
        $tense = "ago";
        for($j = 0; $difference >= $lengths[$j] && $j < count($lengths)-1; $j++)
        {
            $difference /= $lengths[$j];
        }
        $difference = round($difference);
        if($difference != 1)
        {
            $periods[$j].= "s";
        }
        return "$difference $periods[$j]";
    }
}

$app = new app();
$flag = isset($argv[1]) ? $argv[1] : '';
switch($flag)
{
    case 'info':
        $app->info();
        break;
    case 'logout':
        $app->modhash();
        break;
    default:
        $app->start();
        break;
}
