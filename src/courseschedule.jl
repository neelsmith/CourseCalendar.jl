"""Recognized course meeting patterns."""
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

"""Warn if number of topics is not equal to number of
implied class meetings.
"""
function checkdata(startdate, enddate, meets, topics)
    datable = filter(topics) do t
        ! isempty(t) && ! startswith(t, "#")
    end
    totaldates = classcount(startdate, enddate, meets)
    if length(datable) != 
        @warn("Total of $(totaldates) calendar dates on schedule, but $(length(topics)) topics.")
    end
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


"""Segment list of class meeting dates into week-long series, based on
how often the class meets weekly.
"""
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


"""Compute number of class meetings."""
function classcount(sched::CourseSchedule)
    classcount(sched.firstday, sched.lastday, sched.meetson)
end


"""Compute number of class meetings between an inclusive starting and
ending date, based on weekly class meeting pattern.
"""
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


"""Compose a markdown page with course calendar.
"""
function mdcalendar(sched::CourseSchedule; header = false)
    topicentries = filter(sched.topics) do t
        ! isempty(t) && ! startswith(t, "#")
    end
    totalclasses = classcount(sched)
    if length(topicentries) > totalclasses
        throw(DomainError("More topics ($(length(topicentries))) than dates ($(totalclasses))"))
    end


    caldata = filter(ln -> ! isempty(ln), sched.topics)
    mdlines = header ? ["# Calendar for $(sched.title)", ""] : []
    topicidx = 1
    needheading = true
    for wk in weeks(sched)
        @info("Topic idx $(topicidx) ")
        if topicidx <= length(caldata)
            while startswith(caldata[topicidx], "#")
                push!(mdlines, caldata[topicidx])
                push!(mdlines, "")
                topicidx = topicidx + 1
                needheading = true
            end
            if needheading

                lbls = map(d -> dayname(d), wk)
                push!(mdlines, string("| ", join(lbls, " | "), " |"))
                hdrformat = map(d -> ":---",  wk)
                push!(mdlines, string("| ", join(hdrformat, " | "), " |"))
                needheading = false
            end
            if length(caldata[topicidx:end]) >= length(wk)
                cells = []
                for i in 1:length(wk)
                    push!(cells, caldata[topicidx])
                    topicidx = topicidx + 1
                end
                push!(mdlines, string("| ", join(cells," | "), " |"))
            end
        end
    end

    join(mdlines, "\n")
end