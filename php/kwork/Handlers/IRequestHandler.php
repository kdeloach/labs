<?php

interface IRequestHandler
{
    function requestPattern();
    function handleRequest();
}
