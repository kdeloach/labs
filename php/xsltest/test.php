<?php

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT\n");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");

$strxml = file_get_contents('data.xml');

$wrap = new XMLWriter();
$wrap->openMemory();
$wrap->setIndent(4);
$wrap->writeRaw($strxml);

$xml = new DOMDocument();
$xml->preserveWhiteSpace = false;
$xml->loadXML($wrap->outputMemory());

$xsl = new DOMDocument();
$xsl->preserveWhiteSpace = false;
$xsl->load('template.xsl');

$transform = new XSLTProcessor();
$transform->importStylesheet($xsl);

// Compliant xhtml work-around.
$domTranObj = $transform->transformToDoc($xml);
$domTranObj->preserveWhiteSpace = false;
$domTranObj->formatOutput = true;
echo $domTranObj->saveXML();
