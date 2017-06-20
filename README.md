Non-sysadmin issues

1. Are user requests tracked via a ticket system?

	Keeping requests in a database improves sharing within the team. It prevents two people from working on the same issue at the same time. It enables sysadmins to divide work amongst themselves. It enables passing a task from one person to another without losing history. It lets a sysadmin back-fill for one that is out, unavailable or on vacation.

2. Are "the 3 empowering policies" defined and published?

	How does users get help?

		When do they use the ticketing system, and when can they bypass the help desk, and go right to you. (Almost never.)

	What is an emergency?
		An official definition of an emergency enables a sysadmin to set priorities. Without this everything becomes an emergency and sysadmins become interrupt-driven and ineffective.

	What is supported?
		An official definition of what is supported enables sysadmins to say "no". It should define when, where, who, and what is supported. Do you provide support after 5pm? On weekends? Do you provide desk-side visits? Home visits? Do you support anyone off the street or just people in your division? What software and hardware are supported? Is there a support life-cycle or once something is supported are you fated to support it forever? Are new technologies supported automatically or only after an official request and an official positive reply?

3. Does the team record monthly metrics?

	You need to be data-driven when you make decisions or sway upper levels of management.


Modern Team Practices

4. Do you have a "policy and procedure" wiki?

	Your team needs a wiki. On it you can document all your policies (what should be done) and procedures (how it is done).

	Automation is great but before you can automate something you must be able to do it manually. Documenting the manual process for something is a precondition to automation. In the meantime it enables consistent operations across a team and it gains you the ability to delegate. If it is documented, someone other than you can do it.

5. Do you have a password safe?

	This shows you have a mature way to manage passwords.

	There are many excellent software-based password "vaults" systems. Though an envelope in an actual locked box is often good enough.

6. Is your team's code kept in a source code control system?

	We're all programmers now. Programmers use source code control.

	Things to put in your repository: Your scripts, programs, configuration files, documentation, and just about anything. If you aren't sure, the answer is "yes".

7. Does your team use a bug-tracking system for their own code?

	Bug-tracking systems are different than ticket systems. If you have only occasional bugs (maybe your group doesn't write a lot of code) then filing help tickets for yourself is sufficient.

	However if your team is serious about writing code, start a separate bug-tracking system. Bug-tracking systems have a different workflow than request ticket systems. Ticket systems are a communication tool between you and your users. Bug-tracking systems track the bug lifecycle (report, verify, assign, fix, close, verify).

8. In your bugs/tickets, does stability have a higher priority than new features?

Mature teams prioritize bugs this way:

    security (highest)
    stability
    bugs
    performance
    new features (lowest)

You have to fix stability before you add new features. Security issues are high priority stability issues.

9. Does your team write "design docs?"

	Good sysadmin teams "think before they do." On a larger team it is important to communicate what you are about to do, or what you have done.

	A design doc is a standardized format for proposing new things or describing current things. It should be short, 1-2 pages, but can be very long when the need arises.

	Create a template and use it all over the place. The section headings might include: Overview, Goals, Non-Goals, Background, Proposed Solution, Alternatives Considered, Security, Disaster Recovery, Cost.

10. Do you have a "post-mortem" process?

	After a failure do you write up what happened so you can learn from it or do you just hope nobody notices and that it will all go away?

	A good post-mortem (PM) includes a timeline of what happened, who was affected, what was done to fix it, how was business affected, and a list of proposed solutions to prevent this problem from happening again. Each proposal should be filed as a bug or ticket so they can be tracked to completion.

	Doing PMs consistently builds a more stable environment. After each outage come up with at least one preventative measure. Can your monitoring system detect the situation so you know about it before users do? Can you detect precursors to the problem? Often systems have a way to run a battery of tests on new configurations before they are adopted ("pre-submit scripts" in source code repositories, for example). Are there tests you can add that will detect the typo that created the outage?

	A post-mortem is not about blaming and shaming. In a good sysadmin culture you are comfortable with putting your name in the "what went wrong" section.

Operational Practices

11. Does each service have an OpsDoc?

Each service should have certain things documented. If each service documents them the same way, people get used to it and can find what they need easier. I make a sub-wiki (or a mini-web site, or a Google Sites "Site") for each service:

Each of these has the same 7 tabs: (some may be blank)

    Overview: Overview of the service: what is it, why do we have it, who are the primary contacts, how to report bugs, links to design docs and other relevant information.
    Build: How to build the software that makes the service. Where to download it from, where the source code repository is, steps for building and making a package or other distribution mechanisms. If it is software that you modify in any way (open source project you contribute to or a local project) include instructions for how a new developer gets started. Ideally the end result is a package that can be copied to other machines for installation.
    Deploy: How to deploy the software. How to build a server from scratch: RAM/disk requirements, OS version and configuration, what packages to install, and so on. If this is automated with a configuration management tool like cfengine/puppet/chef (and it should be), then say so.
    Common Tasks: Step-by-step instructions for common things like provisioning (add/change/delete), common problems and their solutions, and so on.
    Pager Playbook: A list of every alert your monitoring system may generate for this service and a step-by-step "what do to when..." for each of them.
    DR: Disaster Recovery Plans and procedure. If a service machine died how would you fail-over to the hot/cold spare?
    SLA: Service Level Agreement. The (social or real) contract you make with your customers. Typically things like Uptime Goal (how many 9s), RPO (Recovery Point Objective) and RTO (Recovery Time Objective).

If this is something being developed in-house, the 8th tab would be information for the team: how to set up a development environment, how to do integration testing, how to do release engineering, and other tips that developers will need. For example one project I'm on has a page that describes the exact steps for adding a new RPC to the system.

12. Does each service have appropriate monitoring?

	The monitoring should be based on the SLA from the OpsDoc. If you don't have an SLA, simple "up/down" alerting is the minimum.

13. Do you have a pager rotation schedule?

	An on-call rotation schedule documents who is "carrying the pager" (or responsible for alerts and emergencies) at which times.

	You might literally "pass the pager", handing it to the next person periodically, or everyone might have their own pager and your monitoring system consults a schedule to determine who to page. It is best to have a generic email address that goes to the current person so that customers don't need to know the schedule.

	A rotation schedule can be simple or complex. 1 week out of n (for a team of n people) makes sense if there are few alerts. For more complex situations splitting the day into three 8-hour shifts makes sense.

14. Do you have separate development, QA, and production systems?

	The QA system need not be as expensive as their live counterpart. They don't have to be as powerful as the live system, they can have less RAM and disk and CPU horsepower. They can be virtual machines sharing one big physical machine.

	Obviously if scaling and response time are important it is more likely you'll need a QA system that more closely resembles the live system.

15. Do roll-outs to many machines have a "canary process?"

        Upgrade 1 machine, then 1% of all machines, then 1 machine per second until all machines are done.  This procedure can be done manually but if you use a configuration management system, the ability to do canaries should be "baked in" to the system.

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

(Adapted from Ops Report Card.)