<?php

error_reporting(E_ALL);

function isPostBack()
{
    return isset($_POST) && !empty($_POST);
}

//////////////////////////////////////
// Models

interface EventListener
{
    function handleEvent($eventName, $sender);
}

class PageVersion implements EventListener
{
    var $step;
    var $actions = array();
    var $elements = array();

    function __construct()
    {
    }

    static function load($id)
    {
        $pv = new PageVersion();
        $data = json_decode(file_get_contents('content.json'));
        $pv->step = $data->step;
        $pv->reloadElements();
        $pv->reloadActions();
        return $pv;
    }
    
    function save()
    {
        $data = json_decode(file_get_contents('content.json'));
        $data->step = $this->step;
        $data->elements = $this->elements;
        file_put_contents('content.json', json_encode($data));
    }

    function reloadElements()
    {
        $this->actions = array();
        $data = json_decode(file_get_contents('content.json'));
        foreach($data->elements as $element)
        {
            switch($element->type)
            {
                case 'text':
                    $e = new TextboxElement();
                    $e->name = $element->name;
                    $e->title = $element->title;
                    $e->value = $element->value;
                    $this->elements[] =  $e;
                    break;
            }
        }
    }
    
    function reloadActions()
    {
        $this->actions = array();
        $data = json_decode(file_get_contents('content.json'));
        $workflow = json_decode(file_get_contents('workflow.json'));
        foreach($workflow->{$data->step} as $action)
        {
            $a = new GenericAction();
            $a->name = $action->name;
            $a->title = $action->title;
            if(isset($action->nextstep))
            {
                $a->nextstep = $action->nextstep;
            }
            $a->addEventListener($this);
            $this->actions[] = $a;
        }
    }

    function handleEvent($eventName, $sender)
    {
        if(isset($sender->nextstep))
        {
            $this->step = $sender->nextstep;
        }
        $this->save();
        $this->reloadActions();
    }
}

//////////////////////////////////////
// Views

abstract class View
{
    abstract function render($writer);
}

class PageVersionEditView extends View
{
    var $pageVersion;

    function __construct($pageVersion)
    {
        $this->pageVersion = $pageVersion;
    }

    function render($writer)
    {
        $writer->startElement('page');
        $writer->startElement('actions');
        foreach($this->pageVersion->actions as $action)
        {
            $action->render($writer);
        }
        $writer->endElement();

        $writer->startElement('elements');
        foreach($this->pageVersion->elements as $element)
        {
            $element->render($writer);
        }
        $writer->endElement();
        $writer->endElement();
    }
}

//////////////////////////////////////
// Controllers

class PageVersionEditController
{
    var $view;
    var $pageVersion;

    function __construct()
    {
        $this->pageVersion = PageVersion::load(1);
        $this->view = new PageVersionEditView($this->pageVersion);
    }

    function handlePostBack()
    {
        foreach($this->pageVersion->elements as $element)
        {
            $element->handlePostBack();
        }
        if($action = $this->getSubmittedWorkflowAction())
        {
            $action->applyAction($this->pageVersion);
        }
    }

    function getSubmittedWorkflowAction()
    {
        foreach($this->pageVersion->actions as $action)
        {
            if(isset($_POST[$action->name]))
            {
                return $action;
            }
        }
        return null;
    }
}

//////////////////////////////////////
// Misc. classes

abstract class EventTarget
{
    var $listeners = array();

    function addEventListener($listener)
    {
        $this->listeners[spl_object_hash($listener)] = $listener;
    }

    function dispatchEvent($eventName)
    {
        $args = func_get_args();
        foreach($this->listeners as $listener)
        {
            call_user_func_array(array($listener, 'handleEvent'), $args);
        }
    }
}

abstract class ActionBase extends EventTarget
{
    var $name;
    var $title;
    var $nextstep;

    abstract function applyAction($pv);

    function render($writer)
    {
        $writer->startElement('action');
        $writer->writeAttribute('name', $this->name);
        $writer->writeAttribute('title', $this->title);
        $writer->endElement();
    }
}

class GenericAction extends ActionBase
{
    function __construct()
    {
    }

    function applyAction($pv)
    {
        $e = $pv->elements[0];
        switch($this->name)
        {
            case 'add':
                $e->value += 1;
                break;
            case 'mul':
                $e->value *= 2;
                break;
            case 'div':
                $e->value /= 2;
                break;
            case 'pow':
                $e->value = pow($e->value, 3);
                break;
            case 'sqrt':
                $e->value = sqrt($e->value);
                break;
            case 'round':
                $e->value = round($e->value);
                break;
        }
        $this->dispatchEvent('updatedElements', $this);
    }
}

abstract class ElementBase
{
    var $name;
    var $title;
    var $type;

    abstract function handlePostBack();

    function render($writer)
    {
        $writer->startElement('element');
        $writer->writeAttribute('name', $this->name);
        $writer->writeAttribute('title', $this->title);
        $writer->writeAttribute('type', $this->type);
    }
}

class TextboxElement extends ElementBase
{
    var $value = '';

    function __construct()
    {
        $this->type = 'text';
    }

    function handlePostBack()
    {
        if(isset($_POST[$this->name]))
        {
            $this->value = $_POST[$this->name];
        }
    }

    function render($writer)
    {
        parent::render($writer);
        $writer->startElement('input');
        $writer->writeAttribute('type', 'text');
        $writer->writeAttribute('name', $this->name);
        $writer->writeAttribute('value', $this->value);
        $writer->endElement();
    }
}

//////////////////////////////////////

header('Content-type: text/xml');

$writer = new XMLWriter();
$writer->openURI('php://output');
$writer->startDocument('1.0');
$writer->setIndent(4);
$writer->writePi('xml-stylesheet', 'type="text/xsl" href="template.xsl"');

$controller = new PageVersionEditController();
if(isPostBack())
{
    $controller->handlePostBack();
}
$controller->view->render($writer);

$writer->endDocument();
$writer->flush();
