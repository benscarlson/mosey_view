## TODO

Track information
* Add study_id to study name in tree
* On map, highlight first location and last location
* Text box that updates with description of query.
  e.g. "Showing all points between X and Y dates" for full date range query
* Information section: date of first, last location in query. total number of points
* Draw a rectangle and show how many points are within the rectangle

* Have a date range selector that allows you to highligh all points w/in a certain range (or just all points on a specific day)
* Track data is currently hard-coded to do one point per day. Make this a checkbox
* Handle leap-year issue in slider. (See notes below)
* Add "Zoom to features" button
* Set min/max years on year slider to min/max years in data
* When selecting an individual, set year values on year slider
* Have a simple "color by" dropdown: year, day, individual
* Accept move and ltraj formats. Convert these formats to an internal mvdb format sqlite database
  for use with trackview. Also provide this function with a script interface to convert before using
  trackview
* Add time slider (checkmark for UTC vs. local time)
* Window/box showing sunrise, sunset?
* Label start and end points
* Do I need to be able to select doy for start year, and doy for end year instead?
  * Changing query to fix leapyear issue will fix this
  * Should still have a "use doy" mode, where doy range is used instead of full date range

* Button to highlight start, end points, or highlight a certain date or range of dates
* Need more information on individuals easily viewable. Date range, num points, etc.
* Also when doing date filtering, have a text box that shows total number of points shown
* Put tree of individuals inside a scrolling pane

## Activity log

|Date|Activity|
|:-|:------------|
|2020-07-24|Use JS to update labels display doy as month-day (ignores leap year)|
|2020-06-16|Query is now respecting the doy slider|
|2020-06-04|Used parameterized query to select track data. One point per day|

## Other notes
* Note 1
* Note 2
* Doy slider will give slighly different results if year is a leap year. 
  Day 60 in 2019 is March 1, but day 60 in 2020 is Feb 29. To solve this, simply treat doy as though it is coming from a non-leap year. Construct start end dates using this month/day, and user selected years. Then just filter on these dates. The only negetive implication is that can never view just Feb 29 on a leap year. Can view Feb28-Mar1, which will include Feb29. So, Feb29 will always be included in queries where appropriate. It is just impossible to *only* select Feb29.