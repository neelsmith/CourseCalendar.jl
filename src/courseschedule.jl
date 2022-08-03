@enum MeetingPattern MWF TTh
const patternDict = Dict(
    "MWF" => MWF,
    "TTH" => TTh
)


struct CourseSchedule
    title
    weeks::Int64
    firstday::Date
    lastday::Date
    meetson::MeetingPattern
    fixeddates
end

function classes(schedule::CourseSchedule)
    dr = schedule.firstday:Day(1):schedule.lastday
    if schedule.meetson == MWF
        mwfdays = filter(dr) do d
            Dates.dayofweek(d) == Dates.Mon ||
            Dates.dayofweek(d) == Dates.Wed ||
            Dates.dayofweek(d) == Dates.Fri
        end
        mwfdays
        
    elseif schedule.meetson == TTh
        tthdays = filter(dr) do d
            Dates.dayofweek(d) == Dates.Tue ||
            Dates.dayofweek(d) == Dates.Thu
        end
        tthdays

    else
        @warn("Class schedule not implemented for meeting pattern $(schedule.meetson)")
        nothing
    end
end



"""Construct a `CourseSchedule` from configuration file.
"""
function courseSchedule(configfile)
    config = TOML.parsefile(configfile)
    title = config["courseTitle"]
    weeks = config["totalWeeks"]
    firstday = Date(config["firstDay"])
    lastday = Date(config["lastDay"])
    schedule = patternDict[uppercase(config["schedule"])]


    CourseSchedule(title, weeks, firstday, lastday, schedule,
        config["fixedDates"]
    )
    
end

