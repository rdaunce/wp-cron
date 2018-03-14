# wp-cron
Replaces WordPress cron system with the OS cron system

## Dependencies
wp-cron.sh uses WP-CLI.  [WP-CLI](https://github.com/wp-cli/wp-cli) must be setup and configured properly 
to use this script.

## Installation
Download the file and apply execute permissions

```bash
 $ curl -O -L https://github.com/rdaunce/wp-cron/raw/master/wp-cron.sh
 $ chmod 755 wp-cron.sh
```

Configure the WordPress installations for manual Cron processing by running the script in interactive mode.

```bash
$ wp-cron.sh -i
```

To allow for manual Cron proccessing, toggle DISABLE_WP_CRON to [true] for each WordPress installation that 
should be processed manually.

Once one or more WordPress installations are setup for manual Cron processing, schedule a job in your OS Cron
system to run the script with the `-r` option.  Set a schedule that is appropriate for your WordPress 
installations.  Every 15 minutes should be fine, but there may be plugins that need it more often.

## Usage
```
Usage: wp-cron.sh [options...]
Options:
 -r, --runall           Run all pending WordPress cron tasks on all WordPress installations 
                        that have the WordPress Cron system disabled
 -i, --interactive      Run in interactive mode with menu
 -h, --help             Display help contents
 
 The program will scan locate all WordPress installations recursively within the current directory.
 
 Interactive Mode displays an interactive menu to list all discovered WordPress installations, enable/disable
 the WordPress Cron system for all installations, or toggle the WordPress Cron system on an individual 
 installation.  It also provides an option to run all pending WordPress Cron jobs on all sites that have been 
 setup for manual proccessing. 
 ```
