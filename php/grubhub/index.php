<?php

//define('URL', 'http://www.kevinx.net/labs/php/grubhub');
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

        $pastOrders = array();
        $aggOrders = array();

        // past orders
        $sql = "select name, total, date from past_order where user_hash=? order by date desc";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(array($_SESSION['user_hash']));
        foreach($stmt->fetchAll() as $row)
        {
            $order = new PastOrder();
            $order->name = $row['name'];
            $order->date = strtotime($row['date']);
            $order->total = $row['total'];
            $pastOrders[] = $order;
        }

        // aggregate
        $sql = "select name, count(*) as timesOrdered, sum(total) as total, max(date) as lastDate
                from past_order
                where user_hash=?
                group by name
                order by timesOrdered desc";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(array($_SESSION['user_hash']));
        $i = 0;
        foreach($stmt->fetchAll() as $row)
        {
            $order = new AggregateOrder();
            $order->name = $row['name'];
            $order->timesOrdered = $row['timesOrdered'];
            $order->total = $row['total'];
            $order->lastDate = strtotime($row['lastDate']);
            if($i < 5)
            {
                $order->name = '<strong>' . $order->name . '</strong>';
            }
            $aggOrders[] = $order;
            $i++;
        }

        usort($aggOrders, array($this, '_sortByDate'));

        $grandTotal = array_sum(array_map(array($this, '_orderTotals'), $aggOrders));
        
        include 'templates/dashboard.php';
    }
    
    function _sortByDate($a, $b)
    {
        return $a->lastDate == $b->lastDate ? 0 : $a->lastDate > $b->lastDate ? -1 : 1;
    }
    
    function _orderTotals($order)
    {
        return $order->total;
    }
    
    function showImport()
    {
        if(!isset($_POST['import']))
        {
            return;
        }
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

            $i = 0;
            $this->db->beginTransaction();
            foreach($htmlOrders as $htmlOrder)
            {
                $name = $htmlOrder->find('.restaurantName', 0)->text();
                $name = trim($name);

                $date = $htmlOrder->find('.yourGrubHubColumnWrapper', 0)->plaintext;
				$date = preg_replace('/[a-z]/i', '', $date);
                $date = trim($date);
                $time = strtotime($date);
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

                $i++;
            }
            $this->db->commit();
            if($i < 24)
            {
                echo "Nothing else to import!\n";
                flush();
                break;
            }
        }

        echo 'Complete!</pre><hr />';
        echo '<p><a href="dashboard">Return to Dashboard</a></p>';
    }

    function clearData()
    {
        if(!isset($_POST['clear']))
        {
            return;
        }
        $this->loginRequired();
        $sql = "delete from past_order where user_hash='%s'";
        $sql = sprintf($sql, $_SESSION['user_hash']);
        $this->db->query($sql);
        if(file_exists($this->cookieJarFilename()))
        {
            unlink($this->cookieJarFilename());
        }
        $this->doLogout();
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
    
    function exists($db)
    {
        $sql = "select 1 from past_order where user_hash=? and name=? and total=? and date=?";
        $stmt = $db->prepare($sql);
        $stmt->execute(array(
            $_SESSION['user_hash'],
            $this->name,
            $this->total,
            $this->date));
        $res = $stmt->fetch();
        return $res !== false && count($res) > 0;
    }

    function save($db)
    {
        $sql = "insert into past_order (user_hash, name, total, date) values(?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        $stmt->execute(array(
            $_SESSION['user_hash'],
            $this->name,
            $this->total,
            $this->date));
    }
}

class AggregateOrder
{
    var $name;
    var $timesOrdered;
    var $total;
    var $lastDate;

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
    
    function daysAgo()
    {
        return round((time() - $this->lastDate) / 60 / 60 / 24);
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
