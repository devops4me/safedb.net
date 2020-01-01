#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # This class knows how to derive information from the machine environment to aide
  # in producing identifiers unique to the machine and/or workstation, with functionality
  # similar to that required by licensing software.
  #
  # == Identity is Similar to Licensing Software | Except Deeper
  #
  # Deriving the identity string follows similar principles to licensing
  # software that attempts to determine whether the operating environment
  # is the same or different. But it goes deeper than licensing software
  # as it is not only concerned about the <b>same workstation</b> - it is
  # also concerned about <b>the same shell or command line interface</b>.
  #
  # == Known Issues
  #
  # The dependent macaddr gem is known to fail in scenarios where a
  # VPN tunnel is active and a tell tale sign is the ifconfig command
  # returning the tun0 interface rather than "eth0" or something that
  # resembles "ensp21".
  #
  # This is one of the error messages resulting from such a case.
  #
  #     macaddr.rb:86 from_getifaddrs undefined method pfamily (NoMethodError)
  #
  class MachineId

    # This method uses a one-way function to return a combinatorial digested
    # machine identification string using a number of distinct input parameters
    # to deliver the characteristic of producing the same identifier for the
    # same machine, virtual machine, workstation and/or compute element, and
    # reciprocally, a different one on a different machine.
    #
    # The userspace is also a key machine identifier so a different machine user
    # generates a different identifier when all other things remain equal.
    #
    # @return [String]
    #    a one line textual machine workstation or compute element identifier
    #    that is (surprisingly) different when the machine user changes.
    def self.derive_user_machine_id

      require 'socket'

      identity_text = [
        ENV[ "USER" ],
        get_machine_id(),
        Socket.gethostname()
      ].join.reverse

      return identity_text

    end


    # The machine identifier is a UUID based hash value that is tied to the
    # CPU and motherboard of the machine. This read-only identifier can be
    # accessed without sudoer permissions so is perfect for license generators
    # and environment sensitive software.
    #
    # In the modern era of virtualization you should always check the behaviour
    # of the above identifiers when used inside
    #
    # - docker containers
    # - Amazon EC2 servers (or Azure or GCE)
    # - vagrant (VirtualBox/VMWare)
    # - Windows MSGYWIN (Ubuntu) environments
    # - Kubernetes pods
    #
    # @return [String] the machine ID hash value
    def self.get_machine_id

      machine_id_cmd = "cat /etc/machine-id"
      machine_id_str = %x[ #{machine_id_cmd} ]
      return machine_id_str.chomp

    end


    # This method returns a plaintext string hat is guaranteed to be the same
    # whenever called within the same shell for the same user on the same
    # workstation, virtual machine, container or SSH branch and different whenever
    # a new shell is acquired.
    #
    # What is really important is that the <b>shell identity string changes</b> when
    #
    # - the <b>command shell</b> changes
    # - the user <b>switches to another workstation user</b>
    # - the <b>workstation or machine host</b> is changed
    # - the user <b>SSH's</b> into another shell
    #
    # <b>Unchanged | When Should it Remain Unchanged?</b>
    #
    # Remaining <b>unchanged</b> is a feature that is as important and this must
    # be so when and/or after
    #
    # - the <b>user returns to a command shell</b>
    # - the user <b>switches back to using a domain</b>
    # - the user exits their <b>remote SSH branch</b>
    # - <b>sudo is used</b> to execute the commands
    # - the user comes back to their <b>workstation</b>
    # - the clock ticks into another day, month, year ...
    #
    # @return [String]
    #    Return a one line textual shell identity string.
    #
    #    As key derivation algorithms enforcing a maximum length may be length may
    #    be applied, each character must add value so non-alphanumerics (mostly hyphens)
    #    are cleansed out before returning.
    def self.derive_shell_identifier

      require 'socket'

      # -- Ensure that the most significant data points
      # -- come first just like with numbers.

      identity_text =
      [
        get_bootup_id(),
        ENV[ "USER" ],
        Socket.gethostname()
      ].join

      return identity_text.to_alphanumeric

    end


    # If you need to know whether a Linux computer has been rebooted or
    # you need an identifier that stays the same until the computer reboots,
    # look no further than the read only (non sudoer accessible) **boot id**.
    #
    # In the modern era of virtualization you should always check the behaviour
    # of the above identifiers when used inside
    #
    # - docker containers
    # - Amazon EC2 servers (or Azure or GCE)
    # - vagrant (VirtualBox/VMWare)
    # - Windows MSGYWIN (Ubuntu) environments
    # - Kubernetes pods
    #
    # @return [String] the bootup ID hash value
    def self.get_bootup_id()

      bootup_id_cmd = "cat /proc/sys/kernel/random/boot_id"
      bootup_id_str = %x[ #{bootup_id_cmd} ]
      return bootup_id_str.chomp

    end


    # Logs a list of the last few times that this machine has rebooted.
    # This log can be useful when used in conjunction with the behaviour
    # that gets the bootup identifier.
    def self.log_reboot_times()

      the_cmd = "last reboot"
      the_str = %x[ #{the_cmd} ]
      the_str.log_lines()

    end


    # Return an ancestor process ID meaning return either the parent process
    # ID or the grandparent process ID. The one returned depends on the paremeter
    # boolean value.
    #
    # == Command Used to find the grandparent process ID.
    #
    #     $ ps -fp 31870 | awk "/tty/"' { print $3 } '
    #     $ ps -fp 31870 | awk "/31870/"' { print $3 } '
    #
    # The one liner finds the parental process ID of the process with the given
    # parameter process ID.
    #
    #     $ ps -fp 31870
    #
    #     UID        PID  PPID  C STIME TTY          TIME CMD
    #     joe      31870  2618  0 12:55 tty2     00:01:03 /usr/bin/emacs25
    #
    # The ps command outputs two (2) lines and **awk** is employed to select the
    # line containing the already known ID. We then print the 3rd string in the
    # line which we expect to be the parent PID of the PID.
    #
    # == Warning | Do Not Use $PPID
    #
    # Using $PPID is fools gold because the PS command itself runs as another
    # process so $PPID is this (calling) process ID and the number returned is
    # exactly the same as the parent ID of this process - which is actually the
    # grandparent of the invoked ps process.
    #
    # @param use_grandparent_pid [Boolean]
    #    Set to true if the grandparent process ID is required and false if
    #    only the parent process ID should be returned.
    #
    # @return [String]
    #    Return ancestor process ID that belongs to either the parent process
    #    or the grandparent process.
    def self.get_ancestor_pid( use_grandparent_pid )

      parental_process_id = Process.ppid.to_s()
      grandparent_pid_cmd = "ps -fp #{parental_process_id} | awk \"/#{parental_process_id}/\"' { print $3 } '"
      raw_grandparent_pid = %x[#{grandparent_pid_cmd}]
      the_grandparent_pid = raw_grandparent_pid.chomp

      log.debug(x) { "QQQQQ ~> QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ" }
      log.debug(x) { "QQQQQ ~> Request Bool Use GPPID is ~> [[ #{use_grandparent_pid} ]]" }
      log.debug(x) { "QQQQQ ~> Main Parent Process ID is ~> [[ #{parental_process_id} ]]" }
      log.debug(x) { "QQQQQ ~> GrandParent Process ID is ~> [[ #{the_grandparent_pid} ]]" }
      log.debug(x) { "QQQQQ ~> QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ" }

      return ( use_grandparent_pid ? the_grandparent_pid : parental_process_id )

    end


  end


end
