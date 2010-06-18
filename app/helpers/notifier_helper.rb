module NotifierHelper
  
def list_event_title(lang, event)
if lang == "eng"
"#{event.title}" 
else
  if event.j_title!=""
"#{event.j_title}" 
else
 "#{event.title}"  
end
end
end

def list_event_subtitle(lang,event)
if lang == "eng"
"#{event.subtitle}" 
else
  if event.j_subtitle!=""
"#{event.j_subtitle}" 
else
 "#{event.subtitle}"  
end
end
end

def list_event_links(lang,event)
if lang == "eng"
"#{event.links}" 
else
  if event.j_links!=""
"#{event.j_links}" 
else
 "#{event.links}"  
end
end
end

def list_event_details(lang,event)
if lang == "eng"
"#{event.details}" 
else
if event.j_details!=""
"#{event.j_details}" 
else
"#{event.details}"  
end
end
end

def list_event_venue(lang,venue)
if lang == "eng"
"#{venue.venue_name}" 
else
  if venue.j_venue_name!=""
"#{venue.j_venue_name}" 
else
"#{venue.venue_name}"   
end
end
end

def list_event_place(lang,place)
if lang == "eng"
"#{place.place_name}" 
else
  if place.j_place_name!=""
"#{place.j_place_name}" 
else
"#{place.place_name}"   
end
end
end

end