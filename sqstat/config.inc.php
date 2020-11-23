<?php
/* global settings */

$use_js=true; // use javascript for the HTML toolkits

// Maximum URL length to display in URI table column
DEFINE("SQSTAT_SHOWLEN",60);


/* proxy settings */

/* Squid proxy server ip address or host name */
$squidhost[0]=getenv(SQUIDHOST);
/* Squid proxy server port */
$squidport[0]=getenv(SQUIDPORT);
/* cachemgr_passwd in squid.conf. Leave blank to disable authorisation */
$cachemgr_passwd[0]="";
/* Resolve user IP addresses or print them as numbers only [true|false] */
$resolveip[0]=true;
/* uncomment next line if you want to use hosts-like file.
   See hosts.txt.dist. */
// $hosts_file[0]="hosts.txt"
/* Group users by hostname - "host", by User - "username", by User and Host -
 * "username_and_host" or by User or Host - "username_or_host". Username work
 * only with squid 2.6+ */
$group_by[0]="host";

/* you can specify more than one proxy in the configuration file, e.g.: */
// $squidhost[1]="192.168.0.2";
// $squidport[1]=3129;
// $cachemgr_passwd[1]="secret";
// $resolveip[1]=true;
// $hosts_file[1]="otherhosts.txt"



?>
