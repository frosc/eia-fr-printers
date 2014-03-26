eia-fr-printers
===============

Scripts to help using Konica Minolta Printers of the College of
Engineering and Architecture of Fribourg

*Warning, this project is still in development.*

Before running this script, you should install the "ppd" file from
the "model" directory in "/usr/share/cups/model/" and the
filter from the "filters" directory in "/usr/share/ppd/cupsfilters". Then restart cups
with "sudo restart cups" or "sudo /etc/init.d/cups restart".

You should create a file Secret/hefr_credentials in your home
directory with this data:

username=firstname.lastname

password=YOUR_VERY_SECRET_PASSWORD

domain=sofr
