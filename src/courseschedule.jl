
struct CourseSchedule
    title
    weeks::Int64
    firstday::Date
    schedule
    fixeddates
end

function courseSchedule(configfile)
    config = TOML.parsefile(configfile)
    title = config["courseTitle"]
    weeks = config["totalWeeks"]
    firstday = Date(config["firstDay"])
    schedule = config["schedule"]


    CourseSchedule(title, weeks, firstday, schedule,
        config["fixedDates"]
    )
    
end