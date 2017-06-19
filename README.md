Non-sysadmin issues

1. Are user requests tracked via a ticket system?
2. Are "the 3 empowering policies" defined and published?
3. Does the team record monthly metrics?

Modern Team Practices

4. Do you have a "policy and procedure" wiki?
5. Do you have a password safe?
6. Is your team's code kept in a source code control system?
7. Does your team use a bug-tracking system for their own code?
8. In your bugs/tickets, does stability have a higher priority than new features?
9. Does your team write "design docs?"
10. Do you have a "post-mortem" process?

Operational Practices

11. Does each service have an OpsDoc?
12. Does each service have appropriate monitoring?
13. Do you have a pager rotation schedule?
14. Do you have separate development, QA, and production systems?
15. Do roll-outs to many machines have a "canary process?"

Automation Practices

16. Do you use configuration management tools like cfengine/puppet/chef?

	Config Management (CM) software is a tool that coordinates the configuration of machines. It might control the OS, the software, the service provided, or all of the above.

	Before CM sysadmins manually made changes to machines. If you had to change 100 machines, you had 100 manual tasks to do. Smarter sysadmins would automate such a change.

	Even smarter sysadmins realized that general tools for such automation would be even better. They invented automation frameworks with names like track, cfengine, bcfg2, Puppet, Chef and others.

	The hallmark of CM systems is that you describe what you want and the software figures out how to do it. What you want is specified in declarative statements like "hostA is a web server" and "web servers have the following packages and other attributes". The software turns that into commands that need to be executed. Another important attribute is that the declarations are generic ("install the commands in foo.sh as a cron job") but the CM system does the right thing for that computer's operating system (Selecting "/etc/crontab" vs. "/var/spool/cron").

	With CM, instead of manual changes, you change a configuration file and let the CM system do the work.

17. Do automated administration tasks run under role accounts?

Often we set up automated procedures that run at predetermined times. For example, a script that validates a database once a night.  Some places let these scripts run as one of the sysadmins. When the sysadmin leaves the company those automated processes die.  Good sites run these scripts under some role account, often "root". However, it is safer to run them under an account with less privilege.

18. Do automated processes that generate e-mail only do so when they have something to say?

	Do you know the story of "The Boy Who Cried Wolf"? What about: "The cron job that everyone ignored because it blasted everyone twice a day, and nobody noticed when it started to report problems."

My rule is simple:

    If it needs human action now: Send a page/SMS.
    If it needs action in 24 hours: Create a ticket.
    If it is informational: Log to a file.
    Output nothing if there is no information.


Fleet Management Processes

19. Is there a database of all machines?

	Every site should know what machines it has. The database should store at least some basic attributes: OS, RAM, disk size, IP address, owner/funder, who to notify about maintenance, and so on.  Having a database of all machines enables automation across all your machines. Being able to run a command on precisely the machines with a certain configuration is key to many common procedures.  Having an inventory like this lets you make decisions based on data and helps you prevent problems.

20. Is OS installation automated?

	Automated OS installations are faster, more consistent, and let the users do one more task so you don't have to.  If you can re-install the OS automatically, so can the users. Now you have one less thing to do. Automation that saves you time is great.  Not being able to easily wipe and reload a machine is a security issue. A machine should be wiped and reloaded when a computer moves from one user to another.

21. Can you automatically patch software across your entire fleet?

	If OS installation is automated then all machines start out the same. If patching is automated then all machines stay current. Consistency is a good thing.

	Security updates are very important because the reliability of your systems requires them. Non-security related updates are important because the reliability of your system requires them and because it brings new features to your customers.

	Application patching is just as critical as patching OSs. Users don't make the distinction between "OS" and "application", especially if an application is installed widely. The bad guys that write malware don't make a distinction either.

22. Do you have a PC refresh policy?

	If you don't have a policy about when PC will be replaced, they'll never be replaced.


Disaster Preparation Practices

23. Can your servers keep operating even if 1 disk dies?

	Have you decoupled "component failure" from "outage"?

	Spending a day restoring data off tape isn't just a sign of bad planning, it's bad time management. It is a waste of your time to spend the day consoling a distraught user who has lost years, months, or even just hours, of work. It isn't heroic. It is bad system administration. Let's not forget the bigger waste of time for your users, possibly hundreds of them, waiting for their data to be restored off a backup tape. Disk failures are not rare. Why did you build a system that assumed they are?

	My rule of thumb is simple: For small servers the boot disk should be mirrrored and any disk with user data should be RAID1 or higher.

	Boot disk: I recommend mirroring the boot disk of every server because it is usually impossible to rebuild from scratch. Server boot disks tend to accumulate "stuff". Over the years many software packages may be installed. New drivers, patches and kludges may exist that aren't documented. The configuration is more a history of the company than some well-planned design. In a perfect world none of this would be true. Every machine should be reproducible though an automated system. Alas, that is the goal but we aren't there yet.

	Yes, you could probably rebuild such a server in a day if you are lucky, but a RAID1 controller is less than that in salary if you work minimum wage.

24. Is the network core N+1?

	An outage for one person is a shame. An outage of many people is unacceptable. Just like redundant disks is now a minimum, duplicate network connectivity is, too.

	Yes, it is still expected that there is one link from a workstation to the first switch, but after that everything should be N+1 redundant. At a minimum, all trunks are dual-homed. At best, any one uplink, any one card, or any one network router/switch/hub can die and packets still get through.

	LANs are generally designed as follows: The laptops/desktops in an office plug into the wall jack. Those connect to "access switches" which have many ports. Those access switches have "trunks" that connect to a hierarchy of "core switches" that scoot packets to the right place, possibly to egresses (the connections to other buildings or the Internet).

	My rule is simple: The core has got to be redundant.

25. Are your backups automated?

	You need backups for 4 reasons:

    Oops, I deleted a file.
    Ooops, the hardware died.
    Oh no, the building burned down.
    Archives.

	Each of these may require different backups methodologies.

	Situation (1) is solved by snapshots in the short-term but not in the long term. Sometimes a file is deleted and needs to be restored much later. Simple snapshots will not help. RAID does not help in this situation. RAID is not a backup mechanism. If someone deletes a file by mistake, RAID will dutifully replicate that mistake to all mirrors. You will have a Redundant Array of Incorrect Data.

	Situation (2) sounds like RAID will help, but remember that a double-disk failure can mean you've lost the entire RAID1 mirror or RAID5 set. RAID10 and RAID6 lose all data in a triple-disk failure. These things happen. You are one clumsy electrician away from having all disks blow up at once. Really.

	Situation (3) is often called "disaster recovery". Off-site backups, whether on tape or disk, are your only hope there.

	Situation (4) is often for compliance reasons. The technology to make the backup is often the same as Situation 3 but the retention time is usually different. If some other department is requiring these for compliance, they should pay for the media.

	For any of these reasons the process must be automated. As the building burns down you don't want to have to inform management that the data is lost because "I was on vacation" or "I forgot".

26. Are your disaster recovery plans tested periodically?

	Faith-based backup systems are not good. Hope sustains us but it is not an IT "strategy".  A full test involves simulating a total failure and doing a 'full restore'.

You won't know the real amount of time a restore takes until you try it. Restores from tape often take 10x longer than doing the backup.

27. Do machines in your data center have remote power / console access?

	Remote consoles (IP-based KVM switches) are inexpensive; good servers have them built in. Remote power control isn't a luxury if the computer is more than a few miles away.

Security Practices

28. Do Desktops, laptops, and servers run self-updating, silent, anti-malware software?

	It is your job to enforce the security policy and downloading updates is part of that policy. Delegating that responsibility to a user is wrong and unethical.  Anti-malware software used to be "would be nice" but now it is a requirement. These are my personal rules:

	Anti-malware scanners must run on all machines including any server that contains user-controlled data: home directories, "file shares", web site contents, FTP servers, and so on.
	Scanners must update automatically and silently. No user confirmation.
	There must be a mechanism that lets you detect it has been disabled. They should "check in" with a central server so you can see which machines are no longer being updated.
	Email must be scanned on the server, not on the client (or in addition to the client). Messages with malware must be dropped; messages with spam should be quarantined. You can't trust each individual machine to have the same, high-quality, up-to-date filter as you can maintain on your server. Stop the problem before it gets to the client.

29. Do you have a written security policy?

	It is your job to enforce the security policy and downloading updates is part of that policy. Delegating that responsibility to a user is wrong and unethical.  Anti-malware software used to be "would be nice" but now it is a requirement. These are my personal rules:

	Anti-malware scanners must run on all machines including any server that contains user-controlled data: home directories, "file shares", web site contents, FTP servers, and so on.
	Scanners must update automatically and silently. No user confirmation.
	There must be a mechanism that lets you detect it has been disabled. They should "check in" with a central server so you can see which machines are no longer being updated.
	Email must be scanned on the server, not on the client (or in addition to the client). Messages with malware must be dropped; messages with spam should be quarantined. You can't trust each individual machine to have the same, high-quality, up-to-date filter as you can maintain on your server. Stop the problem before it gets to the client.

30. Do you submit to periodic security audits?

	It is critical to have a written security policy before you implement it.

31. Can a user's account be disabled on all systems in 1 hour?

	Having a single authentication database that all systems rely on is no longer a "would be nice". It is a "must have". If you think you don't need it until you are larger, you will find that you don't have time to install it when you are busy growing.

	The best practice is to employ user account life-cycle management systems. With such a system user accounts are created, managed and controlled from pre-employment through life changes to termination and beyond. What if a user's name changes? What if someone rejoins the company? What if they rejoin the company and their name has changed? There are a lot of "edge cases" they must be able to handle.

32. Can you change all privileged (root) passwords in 1 hour?

	Create a checklist of everywhere it must be changed on a wiki page. Change the password globally by following the list, adding to it as you remember other devices. For obscure systems, document the exact command or process to change the password.