DROP TABLE IF EXISTS `answers`;
CREATE TABLE `answers` (
  `id` int(11) NOT NULL auto_increment,
  `question_id` int(11) default NULL,
  `value` text,
  `correct` int(11) default '0',
  `position` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `quiz_question_id` (`question_id`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `authorships`;
CREATE TABLE `authorships` (
  `id` int(11) NOT NULL auto_increment,
  `tutorial_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rights` int(11) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  KEY `tutorial_id` (`tutorial_id`,`user_id`)
);

DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(255) default NULL,
  `description` text,
  `label` varchar(255) default NULL,
  `book_resource_id` int(11) default NULL,
  `image_id` varchar(55) default NULL,
  `catalog_results` text,
  PRIMARY KEY  (`id`),
  KEY `book_resource_id` (`book_resource_id`)
);
DROP TABLE IF EXISTS `book_resources`;
CREATE TABLE `book_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(255),
  `label` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `content_type` varchar(255) default 'Books',
  `global` int(4) default '0',
  `created_by` varchar(255) default NULL,
  `created_by_id` int(11) default NULL,
  `information` text,
  PRIMARY KEY  (`id`)
);

ALTER TABLE `dods` DROP COLUMN `visible`;
ALTER TABLE `dods` CHANGE `title` `title` varchar(555) NOT NULL default '';
ALTER TABLE `dods` CHANGE `url` `url` varchar(555) NOT NULL default '';
ALTER TABLE `dods` CHANGE `startdate` `startdate` varchar(255) default 'unknown';
ALTER TABLE `dods` CHANGE `enddate` `enddate` varchar(255) default 'unknown';
ALTER TABLE `dods` CHANGE `proxy` `proxy` tinyint(4) default '0';
ALTER TABLE `dods` DROP COLUMN `brief`;
ALTER TABLE `dods` CHANGE `descr` `descr` text NOT NULL;


ALTER TABLE `feeds` CHANGE `label` `label` varchar(255) NOT NULL;
ALTER TABLE `feeds` CHANGE `url` `url` varchar(555) NOT NULL;
ALTER TABLE `feeds` DROP KEY `id_2`;
ALTER TABLE `feeds` ADD KEY `rss_resource_id` (`rss_resource_id`);


DROP TABLE IF EXISTS `images`;
CREATE TABLE `images` (
  `id` int(11) NOT NULL auto_increment,
  `image_resource_id` int(11) default NULL,
  `url` varchar(255) default NULL,
  `description` text,
  `alt` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `image_resource_id` (`image_resource_id`)
);

DROP TABLE IF EXISTS `image_resources`;
CREATE TABLE `image_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(255) NOT NULL,
  `label` varchar(255) default NULL,
  `created_by` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `information` text,
  `global` int(11) default '0',
  `content_type` varchar(255) NOT NULL default 'Images',
  PRIMARY KEY  (`id`)
);

ALTER TABLE `lib_resources`
CHANGE `librarian_name` `librarian_name` VARCHAR( 255 ) NULL DEFAULT NULL ,
CHANGE `office_hours` `office_hours` VARCHAR( 255 ) NULL DEFAULT NULL ,
CHANGE `office_location` `office_location` VARCHAR( 255 ) NULL DEFAULT NULL;

ALTER TABLE `inst_resources`
CHANGE `instructor_name` `instructor_name` VARCHAR( 255 ) NULL DEFAULT NULL ,
CHANGE `office_location` `office_location` VARCHAR( 255 ) NULL DEFAULT NULL ,
CHANGE `office_hours` `office_hours` VARCHAR( 255 ) NULL DEFAULT NULL ;

DROP TABLE IF EXISTS `links`;
CREATE TABLE `links` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(555) default NULL,
  `description` text,
  `label` varchar(255) default NULL,
  `url_resource_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `url_resource_id` (`url_resource_id`)
);

ALTER TABLE `locals` CHANGE `banner_url` `banner_url` varchar(555) default NULL;
ALTER TABLE `locals` CHANGE `logo_url` `logo_url` VARCHAR( 555 ) NULL DEFAULT NULL; 
ALTER TABLE `locals` ADD COLUMN `tutorial_page_title` varchar(255) default 'Online Research Tutorials';
ALTER TABLE `locals` ADD COLUMN `logo_width` int(11) default NULL;
ALTER TABLE `locals` ADD COLUMN `logo_height` int(11) default NULL;
ALTER TABLE `locals` ADD COLUMN `types` text;
ALTER TABLE `locals` ADD COLUMN `guides` text;
ALTER TABLE `locals` ADD COLUMN `proxy` varchar(500) default NULL;   


DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions` (
  `id` int(11) NOT NULL auto_increment,
  `quiz_resource_id` int(11) NOT NULL,
  `question` text NOT NULL,
  `position` int(11) default NULL,
  `points` int(11) default '0',
  `q_type` varchar(55) NOT NULL default 'MC',
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `quiz_resource_id` (`quiz_resource_id`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `quiz_resources`;
CREATE TABLE `quiz_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(255) NOT NULL,
  `label` varchar(255) default NULL,
  `description` text,
  `created_by` varchar(11) default NULL,
  `updated_at` datetime default NULL,
  `content_type` varchar(55) NOT NULL default 'Quiz',
  `graded` int(11) default '0',
  `global` int(11) default '0',
  PRIMARY KEY  (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `resourceables`;
CREATE TABLE `resourceables` (
  `id` int(11) NOT NULL auto_increment,
  `resource_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `resource_id` (`resource_id`,`unit_id`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `results` (
  `id` int(11) NOT NULL auto_increment,
  `student_id` int(11) default NULL,
  `score` int(11) NOT NULL default '0',
  `updated_at` datetime default NULL,
  `question_id` int(11) default NULL,
  `guess` text,
  PRIMARY KEY  (`id`),
  KEY `student_id` (`student_id`),
  KEY `quiz_resource_id` (`question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;



CREATE TABLE `students` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `created_on` datetime default NULL,
  `onid` varchar(55) NOT NULL,
  `sect_num` varchar(55) default NULL,
  `email` varchar(255) NOT NULL,
  `tutorial_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `tutorials`;
CREATE TABLE `tutorials` (
  `id` int(11) NOT NULL auto_increment,
  `subject_id` int(11) default NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `graded` tinyint(4) default '0',
  `published` tinyint(4) NOT NULL default '0',
  `archived` tinyint(4) NOT NULL default '0',
  `created_by` int(11) default NULL,
  `updated_at` datetime default NULL,
  `course_num` varchar(55) default NULL,
  `section_num` text,
  `pass` varchar(55) NOT NULL default 'Ken Kesey',
  PRIMARY KEY  (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `created_by` (`created_by`)
);

DROP TABLE IF EXISTS `unitizations`;
CREATE TABLE `unitizations` (
  `id` int(11) NOT NULL auto_increment,
  `unit_id` int(11) NOT NULL,
  `tutorial_id` int(11) NOT NULL,
  `position` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `unit_id` (`unit_id`,`tutorial_id`)
);

DROP TABLE IF EXISTS `units`;
CREATE TABLE `units` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `description` text,
  `created_by` int(11) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
);

ALTER TABLE `uploader_resources`
 CHANGE `content_type` `content_type` VARCHAR( 255 ) NULL DEFAULT 'Attachments';

DROP TABLE IF EXISTS `url_resources`;
CREATE TABLE `url_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(255) default NULL,
  `label` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `content_type` varchar(255) default 'Web Links',
  `global` int(4) default '0',
  `created_by` varchar(255) default NULL,
  `created_by_id` int(11) default NULL,
  `information` text,
  PRIMARY KEY  (`id`)
);

ALTER TABLE `users` CHANGE `rid` `resource_id` int(11) default NULL;

DROP TABLE IF EXISTS `videos`;
CREATE TABLE `videos` (
  `id` int(11) NOT NULL auto_increment,
  `video_resource_id` int(11) default NULL,
  `url` varchar(255) default NULL,
  `description` text,
  `alt` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `video_resource_id` (`video_resource_id`)
);

DROP TABLE IF EXISTS `video_resources`;
CREATE TABLE `video_resources` (
  `id` int(11) NOT NULL auto_increment,
  `module_title` varchar(255) default NULL,
  `label` varchar(255) default NULL,
  `created_by` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `global` int(11) default '0',
  `content_type` varchar(255) default 'Videos',
  `information` text,
  PRIMARY KEY  (`id`)
);

ALTER TABLE tabs ADD COLUMN page_id int(11);
INSERT INTO tabs (template, page_id,updated_at,position,tab_name) SELECT template,id,updated_at,1,'Quick Start' FROM pages;
INSERT INTO tab_resources (tab_id,resource_id,position)SELECT tabs.id,page_resources.resource_id,page_resources.position from page_resources,tabs where page_resources.page_id = tabs.page_id;
ALTER TABLE pages ENGINE=InnoDB;
ALTER TABLE tabs ENGINE=InnoDB;
alter table tabs add index (page_id);
ALTER TABLE pages DROP COLUMN template;
DROP TABLE page_resources;
ALTER TABLE `tabs` ADD KEY `guide_id` (`guide_id`);
ALTER TABLE `pages` ADD COLUMN `subject` varchar(255) NOT NULL default '';
ALTER TABLE `pages` CHANGE `archived` `archived` tinyint(4) default '0';
ALTER TABLE `pages` CHANGE `course_name` `course_name` varchar(255) NOT NULL;

CREATE TABLE IF NOT EXISTS `image_managers` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `photo_file_name` varchar(255) default NULL,
  `photo_content_type` varchar(255) default NULL,
  `photo_file_size` int(11) default NULL,
  `photo_updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
);

ALTER TABLE lib_resources add column image_info text;

UPDATE lib_resources SET lib_resources.image_info=REPLACE(lib_resources.photo_file_name,'','');
UPDATE lib_resources SET image_info=concat(image_info,'></p>');
UPDATE lib_resources SET image_info=concat('<p><img src=../../photos/photos/original/',image_info);

ALTER TABLE lib_resources DROP photo_file_name;
ALTER TABLE lib_resources DROP photo_content_type;
ALTER TABLE lib_resources DROP photo_file_size;
ALTER TABLE lib_resources DROP photo_updated_at;