@enum MeetingPattern MWF TTh
const patternDict = Dict(
    "MWF" => MWF,
    "TTH" => TTh
)

"""Model of a one-term course's schedule."""
struct CourseSchedule
    title
    firstday::Date
    lastday::Date
    meetson::MeetingPattern
    fixeddates
    topics
    function CourseSchedule(title, day1, daylast, meets, fixed, tops)
        checkdata(day1, daylast, meets, tops)
        new(title, day1, daylast, meets, fixed, tops)
    end
end

function checkdata(startdate, enddate, meets, topics)

end
"""Construct a `CourseSchedule` from a configuration file.
"""
function courseSchedule(configfile, topicsfile)
    config = TOML.parsefile(configfile)
    title = config["courseTitle"]
    weeks = config["totalWeeks"]
    firstday = Date(config["firstDay"])
    lastday = Date(config["lastDay"])
    sched = patternDict[uppercase(config["schedule"])]

    fixed = map(config["fixedDates"]) do pr
        evt_date = Date(pr[1])
        evt_label = pr[2]
        ScheduledEvent(evt_label, evt_date)
    end

    topics = filter(ln -> !isempty(ln), readlines(topicsfile))
    CourseSchedule(title, firstday, lastday, sched,
        fixed, topics
    )    
end



"""Compute vector of weeks, where each week is vector of dates when
classes are scheduled.
"""
function weeks(sched::CourseSchedule)
    weeks(sched.firstday, sched.lastday, sched.meetson)
end

function weeks(day1,lastday, meetson)
    startfrom = Dates.dayofweek(day1) == Dates.Wed || Dates.dayofweek(day1) == Dates.Thu ?     day1 - Dates.Day(2) : day1
    dr =  startfrom:Day(1):lastday
    groups = if meetson == MWF
        mwfdays = filter(dr) do d
            Dates.dayofweek(d) == Dates.Mon ||
            Dates.dayofweek(d) == Dates.Wed ||
            Dates.dayofweek(d) == Dates.Fri
        end
        partitionvect(mwfdays, n = 3)
        
    elseif meetson == TTh
        tthdays = filter(dr) do d
            Dates.dayofweek(d) == Dates.Tue ||
            Dates.dayofweek(d) == Dates.Thu
        end
        partitionvect(tthdays, n = 2)
    end
end


function classcount(sched::CourseSchedule)
    classcount(sched.firstday, sched.lastday, sched.meetson)
end

function classcount(day1, lastday, meetson)
    if meetson == MWF
        3 * length(weeks(day1, lastday, meetson))
    elseif sched.meetson == TTh
        2 * length(weeks(day1, lastday, meetson))
    else
        @warn("CourseSchedule not implemented for $(sched.meetson)")
        0
    end
end