#!/bin/sh
##############################################################################################################
#
# Generates the wifidog config file based on UCI
# 
# Author : GaomingPan
# Date   : 2015-08-05
# Version: 1.0.3
#
###############################################################################################################

version="1.0.3"

WIFI_DOG_CONF_FILE=/etc/wifidog.conf
WIFI_DOG_CONF=/etc/config/wifidog_conf
SINGLE=wifidog_conf.single
AUTH_SERVER=wifidog_conf.authServer
TRUSTED_MAC_LIST=wifidog_conf.trustedMACList
UNTRUSTED_MAC_LIST=wifidog_conf.untrustedMACList
WHITE_LIST=wifidog_conf.whiteBlackList
BLACK_LIST=wifidog_conf.whiteBlackList
FIREWALL_RULE_GLOABL=wifidog_conf.firewallRule_global.FirewallRuleSet_global
FIREWALL_RULE_VALIDATING_USERS=wifidog_conf.firewallRule_validating_users.FirewallRuleSet_validating_users
FIREWALL_RULE_KNOWN_USERS=wifidog_conf.firewallRule_known_users.FirewallRuleSet_known_users
FIREWALL_RULE_UNKNOWN_USERS=wifidog_conf.firewallRule_unknown_users.FirewallRuleSet_unknown_users
FIREWALL_RULE_LOCKED_USERS=wifidog_conf.firewallRule_locked_users.FirewallRuleSet_locked_users


generate_single()
{
    echo "$(uci show $SINGLE | sed 1d | awk -F "=" '{print $2}')" >> $WIFI_DOG_CONF_FILE
}

generate_authServer()
{
    echo "AuthServer {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci show $AUTH_SERVER | sed 1d | \
          awk -F "=" '{print $2}')" >> $WIFI_DOG_CONF_FILE
    echo "}" >> $WIFI_DOG_CONF_FILE
}

generate_trustedMACList()
{
    enable=$(uci get "$TRUSTED_MAC_LIST.enable")
    
    if [ $enable -ne 1 ] 
    then
        return
    fi
    
    echo "TrustedMACList $(uci get "$TRUSTED_MAC_LIST.TrustedMACList" | \
          tr " " ",")" >> $WIFI_DOG_CONF_FILE
}

generate_untrustedMACList()
{
    enable=$(uci get "$UNTRUSTED_MAC_LIST.enable")
    
    if [ $enable -ne 1 ] 
    then
        return
    fi
    
    echo "UntrustedMACList $(uci get "$UNTRUSTED_MAC_LIST.UntrustedMACList" | \
          tr " " ",")" >> $WIFI_DOG_CONF_FILE
}

generate_whiteList()
{
    white_enable=$(uci get "$WHITE_LIST.white_enable")
    
    if [ $white_enable -ne 1 ] 
    then
      return
    fi
    
    echo "WhiteList $(uci get "$WHITE_LIST.WhiteList" | \
           tr " " ",")" >> $WIFI_DOG_CONF_FILE
}


generate_blackList()
{
    black_enable=$(uci get "$BLACK_LIST.black_enable")
    
    if [ $black_enable -ne 1 ] 
    then
      return
    fi
    
    echo "BlackList $(uci get "$BLACK_LIST.BlackList" | \
          tr " " ",")" >> $WIFI_DOG_CONF_FILE
}


generate_firewallRule_global()
{
    echo "FirewallRuleSet global {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci get $FIREWALL_RULE_GLOABL | tr "L" "\n")" >> $WIFI_DOG_CONF_FILE 
    echo "}" >> $WIFI_DOG_CONF_FILE  
}

generate_PopularServer()
{
    echo "PopularServers wifi.xiao8web.com,kernel.org" >> $WIFI_DOG_CONF_FILE
}

generate_firewallRule_validating_users()
{
    echo "FirewallRuleSet validating-users {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci get $FIREWALL_RULE_VALIDATING_USERS | tr "L" "\n")" >> $WIFI_DOG_CONF_FILE 
    echo "}" >> $WIFI_DOG_CONF_FILE  
}

generate_firewallRule_known_users()
{
    echo "FirewallRuleSet known-users {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci get $FIREWALL_RULE_KNOWN_USERS | tr "L" "\n")" >> $WIFI_DOG_CONF_FILE 
    echo "}" >> $WIFI_DOG_CONF_FILE  
}


generate_firewallRule_unknown_users()
{
    echo "FirewallRuleSet unknown-users {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci get $FIREWALL_RULE_UNKNOWN_USERS | tr "L" "\n")" >> $WIFI_DOG_CONF_FILE 
    echo "}" >> $WIFI_DOG_CONF_FILE  
}

generate_firewallRule_auth_is_down()
{
  echo "FirewallRuleSet auth-is-down {"  >> $WIFI_DOG_CONF_FILE
  echo "FirewallRule allow to 0.0.0.0/0" >> $WIFI_DOG_CONF_FILE
  echo "}" >> $WIFI_DOG_CONF_FILE
}

generate_firewallRule_locked_users()
{
    echo "FirewallRuleSet locked-users {" >> $WIFI_DOG_CONF_FILE
    echo "$(uci get $FIREWALL_RULE_LOCKED_USERS | tr "L" "\n")" >> $WIFI_DOG_CONF_FILE 
    echo "}" >> $WIFI_DOG_CONF_FILE  
}

conf_character_check()
{
    
#####
#    delete the single quote ' character,because some uci version will echo ' to the
#    config file.
    sed -i 's/'\''//g'  $WIFI_DOG_CONF_FILE
####
#   delete the blank character at the line header
    sed -i 's/^[[:space:]]*//' $WIFI_DOG_CONF_FILE

####
#   delete the blank character at the line tail
    sed -i 's/[[:space:]]*$//' $WIFI_DOG_CONF_FILE

}

generate_wifidog_conf_file()
{
    echo "###########################################################"  > $WIFI_DOG_CONF_FILE
    echo "## this is wifidog config file"                               >> $WIFI_DOG_CONF_FILE
    echo "## auto generate by dog_conf_generator.sh"                    >> $WIFI_DOG_CONF_FILE
    echo "## Version: $version Based on UCI"                            >> $WIFI_DOG_CONF_FILE
    echo "############################################################" >> $WIFI_DOG_CONF_FILE
    
    generate_single
    generate_authServer
    generate_trustedMACList
    generate_untrustedMACList
    generate_PopularServer
    generate_whiteList
    generate_blackList
    generate_firewallRule_global
    generate_firewallRule_validating_users
    generate_firewallRule_known_users
    generate_firewallRule_unknown_users
    generate_firewallRule_locked_users
    generate_firewallRule_auth_is_down
    
    conf_character_check
}


#echo "------ starting generate wifidog config file --------"

generate_wifidog_conf_file

#echo "------ wifidog config file generate complete --------"

