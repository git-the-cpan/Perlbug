# MySQL dump 6.4
#
# Host: localhost    Database: perlbug
#--------------------------------------------------------
# Server version	3.22.27
use perlbug;

#
# Table structure for table 'tm_bug'
#
CREATE TABLE tm_bug (
  created datetime,
  ts timestamp(14),
  bugid varchar(12) DEFAULT '' NOT NULL,
  subject varchar(100),
  sourceaddr varchar(100),
  toaddr varchar(100),
  status varchar(16) DEFAULT '' NOT NULL,
  severity varchar(16),
  category varchar(16),
  fixed varchar(16),
  version varchar(16),
  osname varchar(16),
  PRIMARY KEY (bugid)
);

#
# Table structure for table 'tm_bug_note'
#
CREATE TABLE tm_bug_note (
  created datetime,
  ts timestamp(14),
  bugid varchar(12) DEFAULT '' NOT NULL,
  noteid bigint(20) DEFAULT '0' NOT NULL
);

#
# Table structure for table 'tm_bug_patch'
#
CREATE TABLE tm_bug_patch (
  created datetime,
  ts timestamp(14),
  bugid varchar(12) DEFAULT '' NOT NULL,
  patchid bigint(20) DEFAULT '0' NOT NULL
);

#
# Table structure for table 'tm_bug_test'
#
CREATE TABLE tm_bug_test (
  created datetime,
  ts timestamp(14),
  bugid varchar(12) DEFAULT '' NOT NULL,
  testid bigint(20) DEFAULT '0' NOT NULL
);

#
# Table structure for table 'tm_bug_user'
#
CREATE TABLE tm_bug_user (
  bugid varchar(12) DEFAULT '' NOT NULL,
  userid varchar(16)
);

#
# Table structure for table 'tm_cc'
#
CREATE TABLE tm_cc (
  bugid varchar(12) DEFAULT '' NOT NULL,
  address varchar(100)
);

#
# Table structure for table 'tm_flags'
#
CREATE TABLE tm_flags (
  type varchar(10) DEFAULT '' NOT NULL,
  flag varchar(15) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_groups'
#
CREATE TABLE tm_groups (
  groupid varchar(16) DEFAULT '' NOT NULL,
  userid varchar(16) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_id'
#
CREATE TABLE tm_id (
  bugid varchar(12) DEFAULT '' NOT NULL,
  PRIMARY KEY (bugid)
);

#
# Table structure for table 'tm_log'
#
CREATE TABLE tm_log (
  ts timestamp(14),
  logid bigint(20) unsigned DEFAULT '0' NOT NULL auto_increment,
  entry blob,
  userid varchar(16),
  bugid varchar(12),
  objectid varchar(16),
  objecttype char(1),
  PRIMARY KEY (logid)
);

#
# Table structure for table 'tm_message'
#
CREATE TABLE tm_message (
  created datetime,
  ts timestamp(14),
  messageid bigint(20) unsigned DEFAULT '0' NOT NULL auto_increment,
  bugid varchar(12) DEFAULT '' NOT NULL,
  subject varchar(100),
  sourceaddr varchar(100),
  toaddr varchar(100),
  msgheader blob,
  msgbody blob,
  PRIMARY KEY (messageid),
  KEY bugid (bugid)
);

#
# Table structure for table 'tm_note'
#
CREATE TABLE tm_note (
  created datetime,
  ts timestamp(14),
  noteid bigint(20) unsigned DEFAULT '0' NOT NULL auto_increment,
  subject varchar(100),
  sourceaddr varchar(100),
  toaddr varchar(100),
  msgheader blob,
  msgbody blob,
  PRIMARY KEY (noteid)
);

#
# Table structure for table 'tm_parent_child'
#
CREATE TABLE tm_parent_child (
  parentid varchar(12) DEFAULT '' NOT NULL,
  childid varchar(12) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_patch'
#
CREATE TABLE tm_patch (
  created datetime,
  ts timestamp(14),
  patchid bigint(20) unsigned DEFAULT '0' NOT NULL auto_increment,
  subject varchar(100),
  sourceaddr varchar(100),
  toaddr varchar(100),
  msgheader blob,
  msgbody blob,
  PRIMARY KEY (patchid)
);

#
# Table structure for table 'tm_patch_change'
#
CREATE TABLE tm_patch_change (
  created datetime,
  ts timestamp(14),
  patchid bigint(20) DEFAULT '0' NOT NULL,
  changeid varchar(12) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_patch_version'
#
CREATE TABLE tm_patch_version (
  created datetime,
  ts timestamp(14),
  patchid bigint(20) DEFAULT '0' NOT NULL,
  version varchar(12) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_test'
#
CREATE TABLE tm_test (
  created datetime,
  ts timestamp(14),
  testid bigint(20) unsigned DEFAULT '0' NOT NULL auto_increment,
  subject varchar(100),
  sourceaddr varchar(100),
  toaddr varchar(100),
  msgheader blob,
  msgbody blob,
  PRIMARY KEY (testid)
);

#
# Table structure for table 'tm_test_version'
#
CREATE TABLE tm_test_version (
  created datetime,
  ts timestamp(14),
  testid bigint(20) DEFAULT '0' NOT NULL,
  version varchar(12) DEFAULT '' NOT NULL
);

#
# Table structure for table 'tm_user'
#
CREATE TABLE tm_user (
  userid varchar(16) DEFAULT '' NOT NULL,
  password varchar(16),
  address varchar(100),
  name varchar(50),
  match_address varchar(150),
  active char(1),
  KEY userid (userid)
);

