<!--- 
You'll need to signup first for 37 signal's HighRise CRM service.  They do have a free version, good for 250 contacts and 2 users

Gotchas:
1) String values, like "Work" or "Other" are CASE SENSITIVE!  So be careful!


WANT TO CONTRIBUTE?
Contact me via http://highrise.RiaForge.com (where the project is hosted) and we'll get you setup.

--->



<!--- define your personal settings here --->
<cfset highriseURL = "https://____________.highrisehq.com" />
<cfset apiToken = ""/>


<cfset highRiseCFC = createobject("component", "highrise").init(highriseURL,apiToken) />



<cfset person = structNew() />
<cfset person.first_name = "Kavitha" />
<cfset person.last_name = "Christo" />
<cfset person.title = "Software Developer" />
<cfset person.company_name = "GreatDentalWebsites.com" />
<cfset person.background = "Met him at a confernece" />

<cfset person.email_addresses = arraynew(1) />
<cfset person.email_addresses[1] = structNew() />
<cfset person.email_addresses[1].email = "kavitha.nelson@colitsys.com" />
<cfset person.email_addresses[1].location = "Work" />
<cfset person.email_addresses[2] = structNew() />
<cfset person.email_addresses[2].email = "kavichris@gmail.com" />
<cfset person.email_addresses[2].location = "Home" />
<cfset person.email_addresses[3] = structNew() />
<cfset person.email_addresses[3].email = "kavisnet@yahoo.co.in" />
<cfset person.email_addresses[3].location = "Other" />

<cfset person.phone_numbers = arraynew(1) />
<cfset person.phone_numbers[1] = structNew() />
<cfset person.phone_numbers[1].number = "123-555-0000" />
<cfset person.phone_numbers[1].location =  "Work"/>
<cfset person.phone_numbers[2] = structNew() />
<cfset person.phone_numbers[2].number = "123-555-1111" />
<cfset person.phone_numbers[2].location =  "Mobile"/>
<cfset person.phone_numbers[3] = structNew() />
<cfset person.phone_numbers[3].number = "123-555-2222" />
<cfset person.phone_numbers[3].location =  "Fax"/>
<!--- possible options for phone numbers:
Work
Mobile
Fax
Pager
Home
Skype
Other
 --->

<cfset newContactID = highRiseCFC.createPerson(argumentcollection=person)>
<cfdump var="#newContactID#">

<!--- Now that we have a new contact ID, let's add a tag associated with this contact! --->

<cfset tag = structNew() />
<cfset tag.subject_id = newContactID /> <!--- newContactID  --->
<cfset tag.name = "Developer" />
<cfset tag.subject_type = "people" />

<cfset newTag = highRiseCFC.addTag(argumentcollection=tag)>
<cfdump var="#newTag#">


<!--- Now lets add a task for someone to follow up with our new contact! --->

<cfset task = structNew() />
<cfset task.task = "email this guy and thank him for making such a great API wrapper" />
<cfset task.frame = "next_week" />
<cfset task.subject_type = "Party" />
<cfset task.subject_id = newContactID /> <!--- newContactID  --->
<cfset task.notifyUser = true /> 
<cfset task.isPublic = true />

<cfset newTask = highRiseCFC.createTask(argumentcollection=task)>
<cfdump var="#newTask#">