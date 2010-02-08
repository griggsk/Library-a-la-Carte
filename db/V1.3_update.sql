--
-- Alter RSS Module
--

ALTER TABLE `rss_resources` ADD `information` TEXT NULL ,
ADD `topic` VARCHAR( 100 ) NOT NULL ,
ADD `num_feeds` INT NOT NULL DEFAULT '6',
ADD `style` VARCHAR( 55 ) NOT NULL DEFAULT 'mixed';

--
-- Create Feed
--

CREATE TABLE `feeds` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`label` VARCHAR( 55 ) NOT NULL ,
`url` VARCHAR( 255 ) NOT NULL ,
`rss_resource_id` INT NOT NULL ,
INDEX ( `rss_resource_id` )
);

--
-- Move data from RSS to Feeds
--
INSERT INTO `feeds` (rss_resource_id, url)
SELECT rss_resources.id, rss_feed_url FROM `rss_resources`;
   
   
--
--Clean up RSS Module
--
ALTER TABLE `rss_resources` DROP `rss_feed_url`; 


--
--Build up pages_subjects table. Move page subjects to join table
-- 
 
INSERT INTO pages_subjects (page_id, subject_id)
SELECT pages.id, subjects.id
FROM pages 
INNER JOIN subjects
ON  pages.subject = subjects.subject_code;


--
--Alter Pages. Add relateds and drop subjects
--

 ALTER TABLE `pages` ADD `relateds` TEXT NULL,  
 DROP `subject`;   