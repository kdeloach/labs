<?php

define('URL', 'http://kevinx.local/labs/php/grubhub');

require 'simple_html_dom.php';

class GrubHubApp
{
    var $db;
    
    function __construct($db)
    {
        $this->db = $db;
    }
    
    function handleRequest()
    {
        session_start();
        switch($_GET['page'])
        {
            case 'login':
                $this->showLogin();
                break;
            case 'logout':
                $this->doLogout();
                break;
            case 'import':
                $this->showImport();
                break;
            case 'clear':
                $this->clearData();
                break;
            case 'disclaimer':
                $this->showDisclaimer();
                break;
            case 'dashboard':
            default:
                $this->showDashboard();
                break;
        }
    }

    function doLogout()
    {
        $_SESSION = array();
        header('Location: ' . URL . '/login');
        exit;
    }

    function loggedIn()
    {
        return isset($_SESSION['user_hash']);
    }

    function loginRequired()
    {
        if(!$this->loggedIn())
        {
            header('Location: ' . URL . '/login');
            exit;
        }
    }

    function showLogin()
    {
        if($this->loggedIn())
        {
            header('Location: ' . URL . '/dashboard');
            exit;
        }
        if(!file_exists($this->cookieDir()))
        {
            mkdir($this->cookieDir());
        }
        if(isset($_POST['login']))
        {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'https://www.grubhub.com/login.action');
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_HEADER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $_POST);
            curl_setopt($ch, CURLOPT_COOKIEJAR, $this->cookieJarFilename());
            $res = curl_exec($ch);
            curl_close($ch);
            if($res !== false && strpos($res, 'Internal Server Error') === false)
            {
                $_SESSION['user_hash'] = md5($_POST['username']);
                header('Location: ' . URL . '/dashboard');
                exit;
            }
        }
        include 'templates/login.php';
    }

    function cookieJarFilename()
    {
        return $this->cookieDir() . DIRECTORY_SEPARATOR . session_id();
    }
    
    function cookieDir()
    {
        return dirname(__FILE__) . DIRECTORY_SEPARATOR . 'cookies';
    }

    function showDashboard()
    {
        $this->loginRequired();

        $top5 = array();
        $pastOrders = array();
        $rankedOrders = array();
        $recentOrders = array();

        // all past orders
        $sql = "select name, total, date from past_order where user_hash='%s' order by date desc";
        $sql = sprintf($sql, $_SESSION['user_hash']);
        $query = $this->db->query($sql);
        foreach($query->fetchAll() as $row)
        {
            $order = new PastOrder();
            $order->name = $row['name'];
            $order->date = strtotime($row['date']);
            $order->total = $row['total'];
            $pastOrders[] = $order;
        }

        // ranked
        $sql = "
            select name, count(*) as timesOrdered, sum(total) as total
            from past_order
            where user_hash='%s'
            group by name
            order by timesOrdered desc";
        $sql = sprintf($sql, $_SESSION['user_hash']);
        $query = $this->db->query($sql);
        $n = 0;
        foreach($query->fetchAll() as $row)
        {
            $order = new RankedOrder();
            $order->name = $row['name'];
            $order->timesOrdered = $row['timesOrdered'];
            $order->total = $row['total'];
            if($n < 5)
            {
                $top5[] = $order->name;
            }
            $rankedOrders[] = $order;
            $n++;
        }

        // recent orders
        $sql = "
            select name, max(date) as lastDate
            from past_order
            where user_hash='%s'
            group by name
            order by lastDate desc";
        $sql = sprintf($sql, $_SESSION['user_hash']);
        $query = $this->db->query($sql);
        foreach($query->fetchAll() as $row)
        {
            $order = new PastOrder();
            $order->name = $row['name'];
            $order->date = strtotime($row['lastDate']);
            if(in_array($order->name, $top5))
            {
                $order->name = '<strong>' . $order->name . '</strong>';
            }
            $recentOrders[] = $order;
        }

        include 'templates/dashboard.php';
    }

    function showImport()
    {
        $this->loginRequired();

        set_time_limit(0);
        
        include 'templates/import.php';
        ob_end_flush();

        $url = 'http://www.grubhub.com/yourGrubHub/pastOrders.action?pageNum=%s';

        for($page = 1, $finished = false; !$finished; $page++)
        {
            echo "Retrieving " . sprintf($url, $page) . "...\n";
            flush();

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, sprintf($url, $page));
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_COOKIEFILE, $this->cookieJarFilename());
            $res = curl_exec($ch);
            curl_close($ch);

            if($res === false || empty($res))
            {
                echo "Could not retrieve data...\n";
                break;
            }

            $html = str_get_html($res);
            $htmlOrders = $html->find('.past_orders');

            $n = 0;
            $this->db->beginTransaction();
            foreach($htmlOrders as $htmlOrder)
            {
                $name = $htmlOrder->find('.restaurantName', 0)->text();
                $name = trim($name);

                $date = $htmlOrder->find('.yourGrubHubColumnInfo', 0)->plaintext;
                $date = trim($date);
                list($year, $month, $day, $hour, $minute) = sscanf($date, 'Enjoyed On %d-%d-%d %d:%d:%d.%d');
                $time = mktime($hour, $minute, 0, $month, $day, $year);
                $date = date('Y-m-d H:i', $time);

                $total = $htmlOrder->find('.totalRow .amountColumn', 0)->plaintext;
                $total = trim($total);
                $total = str_replace('$', '', $total);

                $order = new PastOrder();
                $order->name = $name;
                $order->total = $total;
                $order->date = $date;

                if($order->exists($this->db))
                {
                    $finished = true;
                    echo "Record already exists!\n";
                    flush();
                    break;
                }
                $order->save($this->db);
                echo "Imported {$order->name}...\n";
                flush();

                $n++;
            }
            $this->db->commit();
            if($n < 24)
            {
                echo "Nothing else to import!\n";
                flush();
                break;
            }
        }

        echo 'Complete!</pre>';
        echo '<p><a href="dashboard">Return to Dashboard</a></p>';
    }

    function clearData()
    {
        $this->loginRequired();
        $sql = "delete from past_order where user_hash='%s'";
        $sql = sprintf($sql, $_SESSION['user_hash']);
        $this->db->query($sql);
        header('Location: ' . URL . '/dashboard');
        exit;
    }

    function showDisclaimer()
    {
        include 'templates/disclaimer.php';
    }
}

class PastOrder
{
    var $name;
    var $total;
    var $date;

    function name()
    {
        return $this->name;
    }

    function total()
    {
        return '$' . number_format($this->total, 2);
    }

    function date()
    {
        return date('M j Y g:i A', $this->date);
    }

    function daysAgo()
    {
        return round((time() - $this->date) / 60 / 60 / 24);
    }

    function exists($db)
    {
        $sql = "
            select 1 from past_order po
            where user_hash = '%s' and po.name = '%s' and po.total = '%s' and po.date = '%s'
        ";
        $sql = sprintf($sql,
            $_SESSION['user_hash'],
            sqlite_escape_string($this->name),
            sqlite_escape_string($this->total),
            sqlite_escape_string($this->date));
        $query = $db->query($sql);
        $res = $query->fetch();
        return $res !== false && count($res) > 0;
    }

    function save($db)
    {
        $sql = "
            insert into past_order (user_hash, name, total, date)
            values('%s', '%s', '%s', '%s')
        ";
        $sql = sprintf($sql,
            $_SESSION['user_hash'],
            sqlite_escape_string($this->name),
            sqlite_escape_string($this->total),
            sqlite_escape_string($this->date));
        $db->query($sql);
    }
}

class RankedOrder
{
    var $name;
    // Number of visits
    var $timesOrdered;
    // Total money spent
    var $total;

    function name()
    {
        return $this->name;
    }

    function total()
    {
        return '$' . number_format($this->total, 2);
    }

    function timesOrdered()
    {
        return $this->timesOrdered;
    }
}

$install = !file_exists('db.sq3');
$db = new PDO('sqlite:db.sq3');
if($install)
{
    $db->query('CREATE TABLE past_order (user_hash text, name text, total text, date text);');
}

$app = new GrubHubApp($db);
$app->handleRequest();
