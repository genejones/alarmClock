"""
Fetches events from various calendars (iCal, Exchange) using DavMail
http://blog.ameriks.lv/fetching-exchange-calendar-data-with-python-a
http://davmail.sourceforge.net/
"""

from datetime import datetime
import caldav
from caldav.elements import dav, cdav
from django.utils.encoding import smart_str, smart_unicode
import vobject
import MySQLdb
from icalendar import Calendar, Event
from xml.etree import ElementTree
import gdata.calendar.service
import gdata.service
import atom.service
import gdata.calendar
import atom
import getopt
import sys
import string
import time
 
 
def InsertSingleEvent(calendar_service, title, content, where, start_time=None, end_time=None):
	event = gdata.calendar.CalendarEventEntry()
	event.title = atom.Title(text=title)
	event.content = atom.Content(text=content)
	event.where.append(gdata.calendar.Where(value_string=where))
	event.when.append(gdata.calendar.When(start_time=start_time, end_time=end_time))
	new_event = calendar_service.InsertEvent(event, '/calendar/feeds/default/private/full')	
	return new_event
 
def UpdateEvent(calendar_service, link, title, content, where, start_time=None, end_time=None):
	event = calendar_service.GetCalendarEventEntry(link)
	event.title = atom.Title(text=title)
	event.content = atom.Content(text=content)
	event.where.append(gdata.calendar.Where(value_string=where))
	if start_time is not None:
		event.when.append(gdata.calendar.When(start_time=start_time, end_time=end_time))
	return calendar_service.UpdateEvent(event.GetEditLink().href, event)
 
 
calendar_service = gdata.calendar.service.CalendarService()
calendar_service.email = 'test@gmail.com'
calendar_service.password = 'password'
calendar_service.source = 'Google-Calendar_Python_Sample-1.0'
calendar_service.ProgrammaticLogin()
 
url = "http://username:password@localhost:1080/users/username.other@domain.lv/calendar"
 
conn = MySQLdb.connect(host = "localhost",user = "root",passwd = "password",db = "newDB",use_unicode ="true",charset="UTF8")
 
cursor = conn.cursor()
 
client = caldav.DAVClient(url)
principal = caldav.Principal(client, url)
calendars = principal.calendars()
 
calendar = calendars[0]
 
results = calendar.date_search(datetime.utcnow())
#results = calendar.date_search(datetime(2010, 5, 1))
 
 
for event in results:
	cal = Calendar.from_string(smart_str(event.data))
	ev0 = cal.walk('vevent')[0]
	parsedCal = vobject.readOne(event.data)
	print "Found", parsedCal.vevent.uid.value
	start = parsedCal.vevent.dtstart.value
	end = parsedCal.vevent.dtend.value
	uid = parsedCal.vevent.uid.value
	published_desc = "0"
	description2 = ""
	diff = end-start
	link = ""
	if diff.days == 1:
		cursor.execute ("SELECT * from f7413_calendar where uid = %s", (uid))
		row = cursor.fetchone()
		if row:
			calendar_service.DeleteEvent(row[17])
			cursor.execute('DELETE from f7413_calendar where uid=%s', (uid))
		continue
	try:
		title = str(ev0['SUMMARY']).replace("\\,",",")
		#title = parsedCal.vevent.summary.value
	except:
		title = ""
		pass
	try:
		location = str(ev0['LOCATION']).replace("\\,",",")
		#location = parsedCal.vevent.location.value
	except:
		location = ""
		pass
	try:
		description = str(ev0['DESCRIPTION']).replace("\\,",",")
		#description = parsedCal.vevent.description.value
	except:
		description = ""
		pass
	
	if description != "":
		desc = description.lower()
		publish = desc.split("public\xc4\x93t m\xc4\x81jas lap\xc4\x81")
		if len(publish) > 1:
			published_desc = "1"
		if len(description.split("Virsraksts:")) > 1:
			title = description.split("Virsraksts:")[1].split("\\n")[0].strip()
		if len(description.split("Vieta:")) > 1:
			location = description.split("Vieta:")[1].split("\\n")[0].strip()
		if len(description.split("Apraksts:")) > 1:
			description2 = description.split("Apraksts:")[1].split("\\n")[0].strip()
			
	cursor.execute ("SELECT * from f7413_calendar where uid = %s", (uid))
	row = cursor.fetchone()
	if not row:
		if published_desc == "1":
			googleEvent = InsertSingleEvent(calendar_service, title, description2, location, start.isoformat(), end.isoformat())
			link = googleEvent.GetEditLink().href
		cursor.execute('INSERT INTO f7413_calendar (uid, start, end, title, location, description_raw, created, published_desc, description,google_id) VALUES (%s,%s,%s,%s,%s,%s,now(),%s,%s,%s)', (uid, start.isoformat(), end.isoformat(), title, location, description,published_desc,description2,link))
	else:
		if row[17] != "":
			if published_desc == "1":
				googleEvent = UpdateEvent(calendar_service, row[17], title, description2, location, start.isoformat(), end.isoformat())
				link = row[17]
			else:
				calendar_service.DeleteEvent(row[17])
				link = ""
		else:
			if published_desc == "1":
				googleEvent = InsertSingleEvent(calendar_service, title, description2, location, start.isoformat(), end.isoformat())
				link = googleEvent.GetEditLink().href
		cursor.execute('UPDATE f7413_calendar SET start=%s,end=%s,title=%s,location=%s,description_raw=%s,published_desc=%s,description=%s,google_id=%s where uid=%s', (start.isoformat(), end.isoformat(), title, location, description,published_desc,description2,link,uid))
 
conn.commit()
 
cursor.close ()
conn.close ()