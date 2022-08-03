module CourseCalendar
using CitableBase
using Dates
using TOML

export CourseSchedule, courseSchedule
export mdcalendar


include("courseschedule.jl")
include("events.jl")
include("topics.jl")

end # module
