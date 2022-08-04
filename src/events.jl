
"""An event defined by a string value with an associated `Date`.
"""
struct ScheduledEvent
    evt_label
    evt_day::Date
end