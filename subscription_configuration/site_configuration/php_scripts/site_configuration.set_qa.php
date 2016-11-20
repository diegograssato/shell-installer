<?php
#!/usr/bin/env drush
​​
drush_set_context('DRUSH_AFFIRMATIVE', TRUE);
​
drush_invoke('variable-set', array('file_temporary_path', '/tmp'));
drush_invoke('variable-set', array('file_private_path', '/tmp'));
drush_invoke('variable-set', array('autologout_enforce_admin', '1'));
drush_invoke('variable-set', array('autologout_timeout', '1800'));
drush_invoke('variable-set', array('autologout_padding', '1800'));
drush_invoke('variable-set', array('page_cache_maximum_age', '86400'));
drush_invoke('variable-set', array('cache_lifetime', '0'));
drush_invoke('variable-set', array('cache', '1'));
drush_invoke('variable-set', array('block_cache', '1'));
drush_invoke('variable-set', array('page_compression', '1'));
drush_invoke('variable-set', array('preprocess_css', '1'));
drush_invoke('variable-set', array('preprocess_js', '1'));
drush_invoke('variable-set', array('error_level', '0'));
​
drush_invoke('en', array('autologout','dblog'));
drush_invoke('dis', array('memcache','memcache_admin','syslog'));
​
?>
