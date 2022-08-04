module CourseCalendar
using CitableBase
using Dates
using TOML

export CourseSchedule, courseSchedule
export mdcalendar

include("calendrical.jl")
include("courseschedule.jl")
include("events.jl")


end # module
