<?php

ini_set('html_errors', 0);

class ChessGameServer
{
	function handleRequest($request)
	{
		if(!isset($request->type))
		{
			die('ERROR');
		}
		switch($request->type)
		{
			case 'NewGame':
				unlink('players');
				unlink('gamedata');
				break;
			case 'GetPlayingField':
				$obj = new stdClass();
				$obj->Field = $this->getPlayingField();
				echo json_encode($obj);
				break;
			case 'SetPlayers':
				$obj = file_exists('players') ? json_decode(file_get_contents('players')) : new stdClass();
				$obj->White = isset($obj->White) ? $obj->White : false;
				$obj->Black = isset($obj->Black) ? $obj->Black : false;
				$obj->White = isset($request->data->White) ? $request->data->White : $obj->White;
				$obj->Black = isset($request->data->Black) ? $request->data->Black : $obj->Black;
				$fp = fopen('players', 'w');
				fwrite($fp, json_encode($obj));
				fclose($fp);
				break;
			case 'GetPlayers':
				if(!file_exists('players'))
				{
					$obj = new stdClass();
					$obj->White = false;
					$obj->Black = false;
					echo json_encode($obj);
					break;
				}
				echo file_get_contents('players');
				break;
			case 'Update':
				$ts = strtotime($request->ts);
				$prevts = strtotime($request->prevts);
				
				$field = $this->getPlayingField();
				
				// changes since last update
				$result = new stdClass();
				$result->Changes = array();
				foreach($field as $n => $tile)
				{
					if(isset($tile->SourceTeamColor) && $tile->SourceTeamColor == $request->TeamColor)
					{
						continue;
					}
					if(isset($tile->ts) && $tile->ts >= $prevts)
					{
						$tmp = $tile;
						$tmp->n = $n;
						$result->Changes[] = $tmp;
					}
				}
				
				foreach($request->changes as $change)
				{
					$tmp = new stdClass();
					if(isset($change->PieceName))
					{
						$tmp->PieceName = $change->PieceName;
						$tmp->TeamColor = $change->TeamColor;
					}
					$tmp->ts = $ts;
					$tmp->SourceTeamColor = $request->TeamColor;
					$field[$change->n] = $tmp;
				}
				$fp = fopen('gamedata', 'w');
				fwrite($fp, json_encode($field));
				fclose($fp);
				echo json_encode($result);
				break;
			default:
				$obj = new stdClass();
				$obj->message = "UHOH";
				echo json_encode($obj);
				break;
		}
	}
	
	function getPlayingField()
	{
		if(file_exists('gamedata'))
		{
			return json_decode(file_get_contents('gamedata'));
		}
		$field = array_fill(0, 12 * 6, new stdClass());
		return $field;
	}
}

$request = json_decode($_GET['req']);
$server = new ChessGameServer();

$fp = fopen('lock', 'w');
flock($fp, LOCK_EX);
$server->handleRequest($request);
flock($fp, LOCK_UN);
fclose($fp);
