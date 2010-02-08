
--
-- Table structure for table `uploadables`
--

CREATE TABLE IF NOT EXISTS `uploadables` (
  `id` int(11) NOT NULL auto_increment,
  `upload_file_name` varchar(255) default NULL,
  `upload_content_type` varchar(255) default NULL,
  `upload_file_size` int(11) default NULL,
  `upload_updated_at` datetime default NULL,
  `uploader_resource_id` int(11) default NULL,
  `upload_info` text,
  `upload_link` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `uploader_uploadable` (`id`,`uploader_resource_id`)
);

-- --------------------------------------------------------

--
-- Table structure for table `uploader_resources`
--

CREATE TABLE IF NOT EXISTS `uploader_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(55) default 'Course Materials',
  `label` varchar(255) default NULL,
  `global` int(4) default '0',
  `created_by` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `content_type` varchar(255) default 'Uploaded Materials',
  `info` text,
  PRIMARY KEY  (`id`)
);

-- -------------------------------------------------------

--
-- Alter Table LibResource
--


ALTER TABLE `lib_resources` ADD `photo_file_size` INT NULL ,
ADD `photo_content_type` VARCHAR( 255 ) NULL,
ADD `photo_file_name` VARCHAR( 255 ) NULL,
ADD `photo_updated_at` DATETIME NULL ;

----------------------------------------------------------

