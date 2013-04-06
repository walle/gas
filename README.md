<ul>
  <li style="display: block; float: left; width: 25%; font-size: 28px;">
    <a href="#get_it">Get it</a>
  </li>
  <li style="display: block; float: left; width: 25%; font-size: 28px;">
    <a href="#use_it">Use it</a>
  </li>
  <li style="display: block; float: left; width: 25%; font-size: 28px;">
    <a href="#extend_it">Extend it</a>
  </li>
  <li style="display: block; float: left; width: 25%; font-size: 28px;">
    <a href="#plugins">Plugins</a>
  </li>
</ul>

<br />

Gas helps you manage your git authors. Do you have a personal and a work email and use the same computer to commit. Try gas to help you switch between the two.
Do you pair program and want to reflect that it's not only you writing the code, try gas to switch between your pair user and your regular.

Gas is extensible and it's easy to extend with any functionality you may want.

<a name="get_it"></a>
## Get it

The best way to install gas is with RubyGems:

    $ [sudo] gem install gas

You can install from source:

    $ cd gas/
    $ bundle
    $ rake install

<a name="use_it"></a>
## Use it

### Built-in commands

* add NICKNAME NAME EMAIL - adds a new user to gas
* delete NICKNAME - deletes a user from gas
* import NICKNAME - imports the user from .gitconfig into NICKNAME
* list - lists all users
* plugins - lists all installed plugins
* show - shows the current user
* use NICKNAME - sets the user with NICKNAME as the current user

The default task is to list authors

    $ gas

    $ gas list

This lists the authors that are set up in the ~/.gas/gas.users file.

You can import your current user by giving it a nickname

    $ gas import current_user

To add an author use, add

    $ gas add walle "Fredrik Wallgren" fredrik.wallgren@gmail.com

And the main usage, use

    $ gas use walle

To delete it again use, delete

    $ gas delete walle

View the help using

    $ gas -h

<a name="extend_it"></a>
## Extend it

Gas is built to be extendable, it uses the same way git does. Any executable in your PATH named gas-yourplugin is useable with gas.
This means you can write extensions for gas in any language you want, the only thing you need to do is make it accessable by putting it in PATH.

To extend already existing commands make an executable with the name gas-yourplugin-existingcommand eg. gas-stats-use to do something when the original use command is executed.
This makes it possible to extend plugins too eg. gas-myplugin-stats will extend the stats command, if installed.

An example plugin exists at https://github.com/walle/gas_stats it's written in ruby, and distributed with rubygems. But this is not a requirement.
It extends gas both with adding functionality to built-in commands(counting statistics) and adding own functionality(gas-stats).

<a name="plugins"></a>
## Plugins

### Available plugins

#### gas_stats

Shows usage statistics for gas. Serves as a reference implementation of a plugin.

Code: https://github.com/walle/gas_stats

Installation: $ gem install gas_stats

Author: [Fredrik Wallgren](https://github.com/walle)

#### gas_ssh

Adds ssh support for gas.

Work in progress right now.

Code: https://github.com/TheNotary/gas_ssh

Installation: $ gem install gas_ssh

Author: [TheNotary](https://github.com/TheNotary)
