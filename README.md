.
=======================================
Shell Framework for DevOps

### Initialization
Initialize framework with the command below. It will add to your .bashrc the script home variable and initialize the bash auto completion
  ./sfinit.sh

The auto completion will display the available tasks for execution. Each task has it's own usage:
  sf <task> <params>

### Core modules
The framework core already provides methods for integrating with:
- acquia
- apache
- database
- mysql
- dns
- docker
- drush
- git
- grunt
- slack
- solr
- svn
- yml_loader

### Tasks
Your custom tasks should be created in the `tasks` folder. It is mandatory that you create the `<task>_run()` function inside the `<task>.sh` file, located inside the `tasks/<task>` folder. It is highly recommended that you also create a `<task>_usage()` function to define the expected required and optional parameters.
```
function foobar_usage() {
  if [ ! ${#} -eq 2 ]; then
    out_usage "sf foobar <param 1> <param 2> (<optional param 3>)" 1
    return 1
  else
    return 0
  fi
}
```

### Core configurations
Some core and custom modules require specific configurations. For security reasons, some of these configs are not tracked using .gitignore. They need to be added inside the `config` folder with the correct naming `<module>_config.bash`.

Inside it, you should declare the needed variables. Some modules have a template that you can copy `<module>_config.bash.dist`, just clone it and remove the `.dist` extension.

### Custom modules
To create reusable modules to be used in multiple tasks, place them inside the `modules` folder.

### Importing modules
To allow your tasks to execute any function from Core or Custom modules, import it first from the `<task>.sh file`
```
#!/usr/bin/env bash
import acquia git
```
All `.bash` files are automatically loaded from your task folder, including also the ones from imported modules.

### Standardized output
The core includes built-in output functions to make it your execution log easier to read. It includes functions to express:
- info
- success
- warning
- danger
- raise - Used to launch fatal errors, aborting the script execution.

### Execution analytics
The framework has a metrics module that expose an API to generate execution logs intended to be incorporated by an ELK stack. There you will be able to create dashboards to analyze and track executions and track the health of the scripts.

### Notes
There are some mechanisms to overcome the global configuration `set -o errexit`. It can be used only when your call is expected to fail, like checking if a host is reachable. This is accomplished by adding a `&& true` to the call, which tricks the system in detecting the failure.

### Logs
TBD

### Local filesystem usage
The script will automatically create the following structure:
- **${HOME}/open_solutions/**
  - **acquia/** => Will store Acquia repositories. Used for MTS and MTP.
  - **configs/** => General configuraion files, like the vhost macro file.
  - **files/** => If the remote files server is reachable, will be the mounting point.
  - **offline-metrics/** => If the remote server is unreachable, will store the metrics until it is.
  - **subscriptions/** => Will store the platform/drupal installation.
  - **vendor_subs/** => Will store the Acquia repositories from site builders.
  - **web/** => Will store the local development copy of Drupal/JJBOS Platform. The site repository will be cloned inside it.

### Existing hooks
Just like Drupal hooks, you may create custom hooks or use the built-in available hooks. The existing ones are:
- hook_init
- hook_exit
- hook_abort
