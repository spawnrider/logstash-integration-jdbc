module SagePatches
  module ActiveSupport
    module TimeZone
      extend ::ActiveSupport::Concern

      included do
        alias_method_chain :period_for_local, :ambiguous_handling
      end

      # This monkey patch fixes exceptions like this one:
      # TZInfo::AmbiguousTime: 2014-10-26 01:00:12 UTC is an ambiguous local time.
      # They happen to appear when code like `3.days.ago` or `Time.zone.parse('some ambiguous date here')` is used,
      # i.e. when some local time point can be translated into more than 1 points of time in UTC time, like it's
      # happened in Europe/Moscow on October 26, 2014 when time from 01:00:00 till 01:59:59 went twice:
      # 01:00:00 MSK +04:00 -> 01:59:59 MSK +04:00
      # 01:59:59 MSK +04:00 -> 01:00:00 MSK +03:00
      # 01:00:00 MSK +03:00 -> 02:00:00 MSK +04:00
      # This change is permanent, so no daylight saving time (DST) is involved here
      # See https://github.com/tzinfo/tzinfo/issues/32 for discussion
      #
      # Most of the time TZInfo resolves ambiguous dates by itself, but when it can't we have to choose it manually
      # via supplied block, so take the earlier date by default
      def period_for_local_with_ambiguous_handling(time, dst=true)
        tzinfo.period_for_local(time, dst) { |results| results.first }
      end
    end
  end
end

ActiveSupport::TimeZone.send :include, SagePatches::ActiveSupport::TimeZone
