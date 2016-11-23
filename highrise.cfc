<cfcomponent displayname="HighRiseCFC" hint="Integrates with 37 Signals HighRise CRM product" output="false">

<cffunction name="init" access="public" output="false">
	<cfargument name="highriseURL" required="true" hint="unique url that points to your highrise account" />
	<cfargument name="apiToken" required="true" hint="random generated Auth token.  Get this from your 'My Info' section in highrise account settings" />
	
	<cfset variables.highriseURL = arguments.highriseURL />
	<cfset variables.apiToken = arguments.apiToken />
	
	<cfreturn this>
</cffunction>


<cffunction name="addTag" returntype="numeric" hint="Adds a tag to a person, company, deal, or case." >
	<cfargument name="subject_id" type="numeric" required="true" hint="integer ID of the subject (usually a person) that you want to add a tag to." />
	<cfargument name="name" type="string" required="true" hint="The name of the tag you want to add" />
	<cfargument name="subject_type" type="string" required="false" default="people" hint="'people', 'companies', 'kases', or 'deals'" />
	
	<cfset var cfhttp = "" />

	<!--- Add a tag to a contact--->
	<cfhttp url="#variables.highriseURL#/#arguments.subject_type#/#arguments.subject_id#/tags.xml" method="POST" username="#variables.apiToken#">
	  <cfhttpparam type="header" name="Accept" value="application/xml"/>
	  <cfhttpparam type="header" name="Content-Type" value="application/xml"/>
	  <cfhttpparam type="body" value="<name>#arguments.name#</name>" /> 
	</cfhttp>	

	<!--- did it work? --->
	<cfif cfhttp.status_code eq "201">
		<cfreturn ConvertXmlToStruct(toString(cfhttp.filecontent), structNew()).id />
	<cfelse>
		<!--- it failed!!! --->
		<cfreturn 0 />
	</cfif>
</cffunction>

<cffunction name="createPerson" returntype="numeric" hint="Creates a new person with the currently authenticated user as the author." >
	<cfargument name="first_name" type="string" required="false" default="" hint="" />
	<cfargument name="last_name" type="string" required="false" default="" hint="" />
	<cfargument name="title" type="string" required="false" default="" hint="" />
	<cfargument name="company_name" type="string" required="false" default="" hint="" />
	<cfargument name="background" type="string" required="false" default="" hint="" />
	<cfargument name="email_addresses" type="array" required="false" default="#arrayNew(1)#" hint="" />
	<cfargument name="phone_numbers" type="array" required="false" default="#arrayNew(1)#" hint="" />

	
<!--- 
Creates a new person with the currently authenticated user as the author. The XML for the new person is returned on a successful request with the timestamps recorded and ids for the contact data associated.

Additionally, the company-name is used to either lookup a company with that name or create a new one if it didn’t already exist. You can also refer to an existing company instead using company-id.

By default, a new person is assumed to be visible to Everyone. You can also chose to make the person only visible to the creator using “Owner” as the value for the visible-to tag. Or “NamedGroup” and pass in a group-id tag too.

If the account doesn’t allow for more people to be created, a “507 Insufficient Storage” response will be returned.
 --->
	<cfset var cfhttp = "" />
	<cfset var xmlPacket = "" />
	<cfset var i = 0 />
	
	<cfsavecontent variable="xmlPacket">
 	<cfoutput>
	<person>
	  <first-name>#arguments.first_name#</first-name>
	  <last-name>#arguments.last_name#</last-name>
	  <title>#arguments.title#</title>
	  <company-name>#arguments.company_name#</company-name>
	  <background>#arguments.background#</background>

	  <contact-data>
	  
	  	<!--- do we have any email addresses to add? --->
		<cfif arrayLen(arguments.email_addresses)>
			<email-addresses>
			<cfloop from="1" to="#arraylen(arguments.email_addresses)#" index="i">
				<email-address>
					<address>#arguments.email_addresses[i].email#</address>
					<location>#arguments.email_addresses[i].location#</location>
				</email-address>
			</cfloop>
			</email-addresses>
			<cfset i = 0 /> <!--- reset our iterator --->
		</cfif>
	 
	 	<!--- do we have any phone numbers to add? --->
		<cfif arrayLen(arguments.phone_numbers)>  
		    <phone-numbers>
		    <cfloop from="1" to="#arraylen(arguments.phone_numbers)#" index="i">
		      <phone-number>
		        <number>#arguments.phone_numbers[i].number#</number>
		        <location>#arguments.phone_numbers[i].location#</location>
		      </phone-number>
		      </cfloop>
		    </phone-numbers>
     	</cfif>	
     	
	  </contact-data>
	</person>
	</cfoutput>
	</cfsavecontent>

	<!--- Add a tag to a contact--->
	<cfhttp url="#variables.highriseURL#/people.xml" method="POST" username="#variables.apiToken#">
	  <cfhttpparam type="header" name="Accept" value="application/xml"/>
	  <cfhttpparam type="header" name="Content-Type" value="application/xml"/>
	  <cfhttpparam type="body" value="#xmlPacket#" /> 
	</cfhttp>	

	<!--- did it work? --->
	<cfif cfhttp.status_code eq "201">
		<cfreturn ConvertXmlToStruct(toString(cfhttp.filecontent), structNew()).id />
	<cfelse>
		<!--- it failed!!! --->
		<cfreturn 0 />
	</cfif>

</cffunction>	


<cffunction name="createTask" returntype="numeric" hint="Creates a new task" >
	<cfargument name="task" type="string" required="true" hint="What is this task?" />
	<cfargument name="frame" type="string" required="false" default="today" hint="The possible frames are: today, tomorrow, this_week, next_week, specific, and later.  NOTE: Specific requires additional arguments" />
	<cfargument name="specific" type="date" required="false" default="#now()#" hint="coldfusion datetime object" />
	<cfargument name="subject_type" type="string" required="false" default="" hint="Party|Company|Kase|Deal" />
	<cfargument name="subject_id" type="numeric" required="false" default="0" hint="integer ID of the subject (usually a person) that you want to add a Task for." />
	<cfargument name="category_id" type="numeric" required="false" default="0" hint="" />	
	<cfargument name="recording_id" type="numeric" required="false" default="0" hint="You can also set a recording-id, which will bind the task to that recording and to the subject of that recording. If you do that, you don’t need to specifically set subject-id and subject-type." />	
	<cfargument name="owner_id" type="numeric" required="false" default="0" hint="You can assign this task to someone else by setting the owner-id tag to the id of that user. You can let other users see this task by setting the public tag to true." />	
	<cfargument name="notifyUser" type="boolean" required="false" default="true" hint="If you want to assign the task to someone else, but not trigger an assignment notification email, you can set the notify tag to false. It defaults to true." />
	<cfargument name="isPublic" type="boolean" required="false" default="true" hint=" You can let other users see this task by setting the public tag to true." />



	<cfset var cfhttp = "" />
	<cfset var xmlPacket = "" />
	
	<cfsavecontent variable="xmlPacket">
	<cfoutput>
	<task>
	  <body>#arguments.task#</body>
	  <frame>#arguments.frame#</frame>
	  <cfif arguments.frame eq "specific">
	  <due-at type="datetime">#dateformat(arguments.specific, "yyyy-mm-dd")#T#timeformat(arguments.specific,"long")#</due-at>
	  </cfif>
	  <cfif len(trim(arguments.subject_type))>
	  <subject-type>#arguments.subject_type#</subject-type>
	  </cfif>
	  <cfif arguments.subject_id gt 0>
	  <subject-id type="integer">#arguments.subject_id#</subject-id>
	  </cfif>
	  <cfif arguments.category_id gt 0>
	  <category-id type="integer">#arguments.category_id#</category-id>
	  </cfif>
	  <cfif arguments.recording_id gt 0>
	   <recording-id type="integer">#arguments.recording_id#</recording-id>
	  </cfif>
	  <cfif arguments.owner_id gt 0>
	  <owner-id type="integer">#arguments.owner_id#</owner-id>
	  </cfif>
	  <public type="boolean">#arguments.notifyUser#</public>
	  <notify type="boolean">#arguments.isPublic#</notify>
	</task>

	</cfoutput>
	</cfsavecontent>

	<!--- add the task to highrise --->
	<cfhttp url="#variables.highriseURL#/tasks.xml" method="POST" username="#variables.apiToken#">
	  <cfhttpparam type="header" name="Accept" value="application/xml"/>
	  <cfhttpparam type="header" name="Content-Type" value="application/xml"/>
	  <cfhttpparam type="body" value="#xmlPacket#" /> 
	</cfhttp>
	

	<!--- did it work? --->
	<cfif cfhttp.status_code eq "201">
		<cfreturn ConvertXmlToStruct(toString(cfhttp.filecontent), structNew()).id />
	<cfelse>
		<!--- it failed!!! --->
		<cfreturn 0 />
	</cfif>
</cffunction>	


<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="false" hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
	<cfargument name="xmlNode" type="string" required="true" />
	<cfargument name="str" type="struct" required="true" />
	<!---Setup local variables for recurse: --->
	<cfset var i = 0 />
	<cfset var axml = arguments.xmlNode />
	<cfset var astr = arguments.str />
	<cfset var n = "" />
	<cfset var tmpContainer = "" />
	
	<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
	<cfset axml = axml[1] />
	<!--- For each children of context node: --->
	<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
		<!--- Read XML node name without namespace: --->
		<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
		<!--- If key with that name exists within output struct ... --->
		<cfif structKeyExists(astr, n)>
			<!--- ... and is not an array... --->
			<cfif not isArray(astr[n])>
				<!--- ... get this item into temp variable, ... --->
				<cfset tmpContainer = astr[n] />
				<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
				<cfset astr[n] = arrayNew(1) />
				<!--- ... and reassing temp item as a first element of new array: --->
				<cfset astr[n][1] = tmpContainer />
			<cfelse>
				<!--- Item is already an array: --->
				
			</cfif>
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
			</cfif>
		<cfelse>
			<!---
				This is not a struct. This may be first tag with some name.
				This may also be one and only tag with this name.
			--->
			<!---
					If context child node has child nodes (which means it will be complex type): --->
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
				<!--- recurse call: get complex item: --->
				<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
				<!--- else: assign node value as last element of array: --->
				<!--- if there are any attributes on this element--->
				<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
					<!--- assign the text --->
					<cfset astr[n] = axml.XmlChildren[i].XmlText />
						<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
					 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
					 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
						 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
						 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
					</cfif>
				<cfelse>
					 <cfset astr[n] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- return struct: --->
	<cfreturn astr />
</cffunction>
	<!--- 

<cfscript>
/**
* Convert a date in ISO 8601 format to an ODBC datetime.
* 
* @param ISO8601dateString      The ISO8601 date string. (Required)
* @param targetZoneOffset      The timezone offset. (Required)
* @return Returns a datetime. 
* @author David Satz (david_satz@hyperion.com) 
* @version 1, September 28, 2004 
*/
function DateConvertISO8601(ISO8601dateString, targetZoneOffset) {
    var rawDatetime = left(ISO8601dateString,10) & " " & mid(ISO8601dateString,12,8);
    
    // adjust offset based on offset given in date string
    if uCasee(mid(ISO8601dateString,20,1)) neq "Z")
        targetZoneOffset = targetZoneOffset - val(mid(ISO8601dateString,20,3)) ;
    
    return DateAdd("h", targetZoneOffset, CreateODBCDateTime(rawDatetime));

}
</cfscript>	
 --->

	
</cfcomponent>







