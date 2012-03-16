<?php

error_reporting(E_ALL);

set_time_limit(0);
date_default_timezone_set('UTC');

define('ROOT', dirname(__FILE__) . DIRECTORY_SEPARATOR);

define('TYPE_UNIQUE', 0);
define('TYPE_STRANGE', 1);
define('TYPE_VINTAGE', 2);
define('TYPE_GENUINE', 3);
define('TYPE_HAUNTED', 4);

require ROOT . 'simple_html_dom.php';

class Entry
{
    var $itemID;
    var $name;
    var $type;
    var $date;
    var $price;
    var $strangePrice;
    var $vintagePrice;
    var $genuinePrice;
    var $hauntedPrice;

    function __construct($name=null, $type=null, $price=null, $date=null)
    {
        $this->name = $name;
        $this->type = $type;
        $this->price = $price;
        $this->date = $date;
    }

    function displayName()
    {
        switch($this->type)
        {
            case TYPE_STRANGE:
                return 'Strange ' . $this->name;
            case TYPE_VINTAGE:
                return 'Vintage ' . $this->name;
            case TYPE_GENUINE:
                return 'Genuine ' . $this->name;
            case TYPE_HAUNTED:
                return 'Haunted ' . $this->name;
            case TYPE_UNIQUE:
            default:
                return $this->name;
        }
    }

    function getJSONObject()
    {
        $result = new stdClass();
        $result->itemID = (int)$this->itemID;
        $result->name = $this->displayName();
        if($this->type != null)
        {
            $result->type = (int)$this->type;
        }
        $result->price = (int)$this->price;
        if($this->date != null)
        {
            $result->date = $this->date;
        }
        if($this->strangePrice != null)
        {
            $result->strangePrice = (int)$this->strangePrice;
        }
        if($this->vintagePrice != null)
        {
            $result->vintagePrice = (int)$this->vintagePrice;
        }
        if($this->genuinePrice != null)
        {
            $result->genuinePrice = (int)$this->genuinePrice;
        }
        if($this->hauntedPrice != null)
        {
            $result->hauntedPrice = (int)$this->hauntedPrice;
        }
        return $result;
    }
}

class PriceListParser
{
    function getPrices()
    {
        $result = array();
        $html = str_get_html(file_get_contents('http://www.tf2wh.com/pricelist.php'));
        if($html === false)
        {
            return false;
        }
        $pricelist = $html->find('#pricelist', 0);
        $rows = $pricelist->find('tr');
        // First two rows are column titles
        array_shift($rows);
        array_shift($rows);
        $time = time();
        foreach($rows as $row)
        {
            // XXX: The source HTML has unclosed th tags so the parser put the subsequent td cells inside the th?
            $th = $row->first_child();
            $name = trim($th->nodes[0]->text());
            list($baseNode, , $strangeNode, , $vintageNode, , $genuineNode, , $hauntedNode) = $th->children();
            $basePrice = $this->cleanPrice($baseNode->text());
            $strangePrice = $this->cleanPrice($strangeNode->text());
            $vintagePrice = $this->cleanPrice($vintageNode->text());
            $genuinePrice = $this->cleanPrice($genuineNode->text());
            $hauntedPrice = $this->cleanPrice($hauntedNode->text());
            if(!empty($basePrice))
            {
                $result[] = new Entry($name, TYPE_UNIQUE, $basePrice, $time);
            }
            if(!empty($strangePrice))
            {
                $result[] = new Entry($name, TYPE_STRANGE, $strangePrice, $time);
            }
            if(!empty($vintagePrice))
            {
                $result[] = new Entry($name, TYPE_VINTAGE, $vintagePrice, $time);
            }
            if(!empty($genuinePrice))
            {
                $result[] = new Entry($name, TYPE_GENUINE, $genuinePrice, $time);
            }
            if(!empty($hauntedPrice))
            {
                $result[] = new Entry($name, TYPE_HAUNTED, $hauntedPrice, $time);
            }
        }
        return $result;
    }

    function cleanPrice($text)
    {
        return str_replace(',', '', trim($text));
    }
}

class TF2App
{
    var $db;

    function __construct($db)
    {
        $this->db = $db;
    }

    function handleRequest()
    {
        $context = isset($_GET['context']) ? $_GET['context'] : '';
        switch($_GET['page'])
        {
            case 'install':
                $this->install();
                break;
            case 'update':
                $this->update();
                break;
            case 'prices':
                $this->showPrices($context);
                break;
            case 'pricespivot':
                $this->showPricesPivot($context);
                break;
            case 'changes':
                $this->showChanges($context);
                break;
            default:
                $this->showTargetPrices($_GET['page'], $context);
                break;
        }
    }

    function install()
    {
        exit;
        $this->db->exec('drop table item');
        $this->db->exec('drop table price');
        $this->db->exec('
            create table item (
                id integer primary key autoincrement,
                name varchar(50)
            )
        ');
        $this->db->exec('
            create table item_price (
                item_id integer,
                type integer,
                price varchar(10),
                date integer)
        ');
        $this->update();
    }

    function update()
    {
        $parser = new PriceListParser();
        $item_stmt = $this->db->prepare('
            insert or replace into item (name, id) values (:name, (select id from item where name=:name))
        ');
        $price_stmt = $this->db->prepare('
            insert into item_price (item_id, type, price, date) values((select id from item where name=?), ?, ?, ?)
        ');
        $this->db->beginTransaction();
        foreach($parser->getPrices() as $entry)
        {
            $item_stmt->execute(array(
                ':name' => $entry->name
            ));
            $price_stmt->execute(array(
                $entry->name,
                $entry->type,
                $entry->price,
                $entry->date
            ));
        }
        $this->db->commit();
        $file = ROOT . 'cache/changes.json';
        if(file_exists($file))
        {
            unlink($file);
        }
    }

    function showPrices($context)
    {
        if($context == 'json')
        {
            $stmt = $this->db->prepare('
                select i.id as itemID, i.name as name, ip.type as type, ip.price as price
                from item i
                inner join item_price ip on ip.item_id = i.id
                group by i.name, ip.type, ip.date
                having ip.date=(select max(date) from item_price)
                order by i.name, ip.date, ip.type
            ');
            $stmt->execute();
            $entries = $stmt->fetchAll(PDO::FETCH_CLASS | PDO::FETCH_PROPS_LATE, 'Entry');
            $result = array();
            foreach($entries as $entry)
            {
                $result[] = $entry->getJSONObject();
            }
            header('Content-Type: application/json');
            echo json_encode($result);
        }
        else
        {
            include ROOT . 'templates/prices.html';
        }
    }

    function showTargetPrices($target, $context)
    {
        if($context == 'json')
        {
            $targetIDs = explode(' ', $target);
            $targetIDs = array_filter($targetIDs);
            $targetIDs = array_unique($targetIDs);
            $arrWhere = array();
            $arrWhere2 = array();
            $arrJoin = array();
            $arrSelect = array('dd.date');
            $t = 0;
            foreach($targetIDs as $id)
            {
                // Default to 'unique' or normal price if no type specified
                if(!strstr($id, ','))
                {
                    $id .= ',0';
                }
                list($id, $type) = explode(',', $id);
                $clause = '(item_id=' . sqlite_escape_string($id) . ' and type=' . sqlite_escape_string($type) . ')';
                $arrJoin[] = "(select price, date from item_price where $clause) t$t on t$t.date=dd.date";
                $arrWhere[] = $clause;
                $arrWhere2[] = 'select name, ' . sqlite_escape_string($type) . ' as type from item where id=' . sqlite_escape_string($id);
                $arrSelect[] = "t$t.price";
                $t++;
            }
            $sqlWhere = implode(' or ', $arrWhere);
            $sqlWhere2 = implode(' union ', $arrWhere2);
            array_unshift($arrJoin, "(select distinct date from item_price where $sqlWhere) dd");
            $sqlJoin = implode(' left join ', $arrJoin);
            $sqlSelect = implode(',', $arrSelect);
            $sql = "select $sqlSelect from $sqlJoin order by dd.date";
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $entries = $stmt->fetchAll(PDO::FETCH_NUM);
            // XXX
            foreach($entries as $k => $row)
            {
                foreach($row as $i => $val)
                {
                    if($val != null)
                    {
                        $entries[$k][$i] = (int)$val;
                    }
                }
            }
            $result = array();
            $result['entries'] = $entries;
            $stmt = $this->db->prepare($sqlWhere2);
            $stmt->execute();
            $names = $stmt->fetchAll(PDO::FETCH_CLASS | PDO::FETCH_PROPS_LATE, 'Entry');
            $result['legend'] = array();
            $result['legend'][] = array('title' => 'Date', 'type' => 'date');
            foreach($names as $entry)
            {
                $result['legend'][] = array('title' => $entry->displayName(), 'type' => 'number');
            }
            header('Content-Type: application/json');
            echo json_encode($result);
        }
        else
        {
            include ROOT . 'templates/prices.html';
        }
    }

    function showPricesPivot($context)
    {
        if($context == 'json')
        {
            $stmt = $this->db->prepare('
                select i.id as itemID, i.name as name, a.price as price, b.price as strangePrice, c.price as vintagePrice, d.price genuinePrice, e.price hauntedPrice
                from item i
                left join (select item_id, price from item_price where type=0 group by item_id, date having date=(select max(date) from item_price)) a on a.item_id = i.id
                left join (select item_id, price from item_price where type=1 group by item_id, date having date=(select max(date) from item_price)) b on b.item_id = i.id
                left join (select item_id, price from item_price where type=2 group by item_id, date having date=(select max(date) from item_price)) c on c.item_id = i.id
                left join (select item_id, price from item_price where type=3 group by item_id, date having date=(select max(date) from item_price)) d on d.item_id = i.id
                left join (select item_id, price from item_price where type=4 group by item_id, date having date=(select max(date) from item_price)) e on e.item_id = i.id
                group by i.name order by i.name
            ');
            $stmt->execute();
            $entries = $stmt->fetchAll(PDO::FETCH_CLASS | PDO::FETCH_PROPS_LATE, 'Entry');
            $result = array();
            foreach($entries as $entry)
            {
                $result[] = $entry->getJSONObject();
            }
            header('Content-Type: application/json');
            echo json_encode($result);
        }
        else
        {
            include ROOT . 'templates/pricespivot.html';
        }
    }

    function showChanges($context)
    {
        if($context == 'json')
        {
            $file = ROOT . 'cache/changes.json';
            if(file_exists($file))
            {
                $result = file_get_contents($file);
            }
            else
            {
                $result = json_encode($this->showchangesBuildOutput());
                file_put_contents($file, $result);
            }
            header('Content-Type: application/json');
            echo $result;
        }
        else
        {
            include ROOT . 'templates/changes.html';
        }
    }

    function showChangesBuildOutput()
    {
        $stmt = $this->db->query('
            select d1.date d1, max(d2.date) d2 from
            (select distinct date as date from item_price) d1
            cross join (select distinct date as date from item_price) d2
            where d2.date < d1.date
            group by d1.date
            order by d1.date desc
        ');
        $dates = $stmt->fetchAll(PDO::FETCH_NUM);
        $stmt = $this->db->prepare('
            select i.id, i.name, ip.type, ip.price, ip.price - ip2.price from item i
            inner join item_price ip on ip.item_id=i.id and ip.date=:d1
            inner join item_price ip2 on ip2.item_id=i.id and ip2.type=ip.type and ip2.date=:d2
            where ip.price <> ip2.price
            order by ip.type, i.name
        ');
        $result = array();
        $n = 0;
        foreach($dates as $row)
        {
            if($n >= 3)
            {
                break;
            }
            list($d1, $d2) = $row;
            $file = ROOT . "cache/changes_$d1.json";
            if(file_exists($file))
            {
                $result[] = json_decode(file_get_contents($file));
                $n++;
                continue;
            }
            $stmt->execute(array(
                ':d1' => $d1,
                ':d2' => $d2
            ));
            $changes = $stmt->fetchAll(PDO::FETCH_NUM);
            if(count($changes) == 0)
            {
                continue;
            }
            $changelist = array(
                'd1' => $d1,
                'd2' => $d2,
                'changes' => array()
            );
            foreach($changes as $crow)
            {
                list($itemID, $name, $type, $price, $change) = $crow;
                $changelist['changes'][] = array(
                    'itemID' => (int)$itemID,
                    'name' => $name,
                    'type' => (int)$type,
                    'price' => (int)$price,
                    'change' => (int)$change
                );
            }
            file_put_contents($file, json_encode($changelist));
            $result[] = $changelist;
            $n++;
        }
        return $result;
    }
}

$app = new TF2App(new PDO('sqlite:' . ROOT . 'db.sq3'));
$app->handleRequest();
