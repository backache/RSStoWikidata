#Get  URL
$Q = "Q110568256","Q110555760","Q110555892","Q110555967","Q110555971","Q110568022","Q110568242","Q110568415","Q110568422","Q110568439","Q110568469","Q110568531","Q110568580","Q110568630","Q110568634","Q110568650","Q110568719","Q110568737","Q110568752","Q110568759","Q110568766","Q110568782","Q110568811","Q110568827","Q110568844","Q110568866","Q110568865","Q110568868","Q110568875","Q110568878","Q110568895","Q110568908","Q110568909","Q110568930","Q110568939","Q110568937","Q110568946","Q110568958","Q110568960","Q110568972","Q110573469","Q110573483","Q110573486","Q110573495","Q110573492","Q110573498","Q110573503","Q110573514","Q110573519","Q110573531","Q110573529","Q110573541","Q110573546","Q110573545","Q110573555","Q110573553","Q110573557","Q110573564","Q110573565","Q110573568","Q110573586","Q110573587","Q110573592","Q110573598","Q110573596","Q110573602","Q110573607","Q110573610","Q110573619","Q110573630","Q110573632","Q110573640","Q110573647","Q110573670","Q110573669","Q110573693","Q110573713","Q110573718","Q110573722","Q110573727","Q110573756","Q110573775","Q110573777","Q110573790","Q110573807","Q110573804","Q110573808","Q110573852","Q110573857","Q110573886","Q110573885","Q110573889","Q110573923","Q110573971","Q110573992","Q110574005","Q110574015","Q110574012","Q110574018","Q110574019"
#to do
# get the podcast logo URL and put it in P10286
# take <itunes:category text="Education"> and set it as genre
# get <link> and make it official website
function Send-Wikidata {

    param (
        $QID
    )
    $out =""
    $language = @{
        'en'    = 'Q1860'
        'de'    = 'Q188'
        'de-de'    = 'Q188'
        'fr'    = 'Q150'
        'es'    = 'Q1321'
        'en-us' = 'Q7976'
        'en-ph' = 'Q1413694'
        'en-gb' = 'Q7979'
        'pl'    = 'Q809'
        'nl'    = 'Q7411' 
        'pt-br' = 'Q750553'
        'pt' = 'Q5146'
        'en-au' ='Q44679'
        'en-ca' = 'Q44676'
        'en_US' = 'Q7976'
        'es-mx' = 'Q616620'
        'es_mx' = 'Q616620'
        'es-ES'= 'Q1321'
        'tr' = 'Q256'
        'it' = 'Q652'
    }

    #Retrieve the wikidata item and put in a variable called WD then show me what you got
    $Response = Invoke-WebRequest -Uri "https://wikidata.org/w/rest.php/wikibase/v0/entities/items/$QID" -UseBasicParsing
    If ($Response.StatusCode -ne "200") {
        # WD failed to respond.
        Write-Host "Message: $($Response.StatusCode) $($Response.StatusDescription)"
    }

    #Make a dictionary of the response from Wikidata
    $WD = $response | ConvertFrom-Json
    #$WD
    #if more than one $URL=$WD.statements.p1019.value.content[1]
    #if just one $URL=$WD.statements.p1019.value.content
   
    #From the WIkidate Dictionary  extra the value of the web feed URL
    $URL = $WD.statements.p1019.value.content | Select-Object -first 1

    # Go and get the RSS file
    try {
        $Response = Invoke-WebRequest -Uri "$URL" -UseBasicParsing -ContentType "application/xml"

        $FeedXml = [xml]$Response.Content

        # Exract recent entries (currently set for updated within the last 24 hours)
        ForEach ($Entry in $FeedXml.feed.entry) {

           $URL=$Entry 
        }

        $chfeed = [xml](Invoke-WebRequest "$URL")
        #$chfeed.rss.channel.item | Select-Object pubDate
        $countitems = 0
        [datetime] $oldestdate = "1972-08-14"
        [datetime] $newestdate = "1972-08-14"

        ForEach ($Entry in $chfeed.rss.channel.item) {

            $found = $Entry.pubDate -match '(\d\d \w\w\w\ \d\d\d\d)'
            #$found
            if ($found) {
                $epdate = $matches[1]
            }
            [datetime] $date = [datetime] $epdate
            if ($oldestdate = "1972-08-14") { $oldestdate = $date }
            #if ($newestdate="1972-08-14") {$newestdate=$date}
            if ($date -lt $oldestdate) { $oldestdate = $date }
            if ($date -gt $newestdate) { $newestdate = $date }
            $countitems += 1
        }
#Write-Output "For podcast $QID $countitems episodes found"
        #$title=$chfeed.rss.channel.title.replace("|","%7C")
        $date = Get-Date
        $datestr = $date.ToString("yyyy-MM-dd")
        #get the largest number of podcasts the wididata entry has
        $amountnum=0
        $currentcount=0
        ForEach ($CountEntry in $WD.statements.p1113.value.content.amount) {
    
            if ($CountEntry.length -gt 0) {$currentcount = $CountEntry.Substring(1)}
            if ($currentcount -gt $amountnum) {$amountnum=$currentcount} 
         }
        if ($countitems -gt $amountnum) {$out = "%7C%7C$QID%7CP1113%7C$countitems%7CP585%7C%2b$($datestr)T00:00:00Z%2F11"}
        #Start-Process "chrome.exe" "$output"
        #Write-output $output
        if ($WD.statements.p407.value.content.length -eq 0){
        $lang = $chfeed.rss.channel.language.innertext
        #$lang.length
        if ($lang.length -eq 0) {$lang = $chfeed.rss.channel.language}
        #Write-Output "Its raw language is $lang"
        $lang = $language[$lang.ToLower()]
                $out += "%7C%7C$QID%7CP407%7C$($lang)"
        }
        #$chfeed.rss.channel.language
        #Start-Process "chrome.exe" "$output"
        #Write-output $out

        #$title = [uri]::EscapeDataString($chfeed.rss.channel.title)
        #$output="https://quickstatements.toolforge.org/#/v1=%7C%7C$QID%7CP1476%7C$($title)"
        #Write-output $output

        #$QID+"|P1476|"+$title+"|P580|"+$oldestdate+"|P1113|"+$countitems+"|S585|"+$date

        #$oldestdate
        #$newestdate

        #$chfeed.rss.channel.subtitle
        #If it doesn't have a home page get one from the feed
        #Write-Output "For podcast $QID WD has *$($WD.statements.p856.value.content.length)* and the feed has $($chfeed.rss.channel.link| Where-Object { $_.rel.length -eq 0})"

        if ($WD.statements.p856.value.content.length -eq 0){
         #   Write-Output "set it"

            $homepage=$chfeed.rss.channel.link| Where-Object { $_.rel.length -eq 0}
            $homepage=[System.Web.HTTPUtility]::UrlEncode($homepage)
            $out += "%7C%7C$QID%7CP856%7C""$homepage"""
        }
        
    }
    catch {} 
    return $out
}

$output = "https://quickstatements.toolforge.org/#/v1="

foreach ($Qitem in $Q) {
    $itemoutput = Send-Wikidata($Qitem)
    $output = $output + $itemoutput
}
$output
#   Start-Process "chrome.exe" "$output"
