require 'sage_patches/active_support/time_zone'
require 'activesupport'
require 'timecop'

describe SagePatches::ActiveSupport::TimeZone do
  describe 'ambigious time bug' do
    # I could reproduce this bug only on Rails 3.x
    it 'n.days.ago should not throw exception' do
      Timecop.travel(Time.zone.parse('27.10.2014 1:30:00 MSK +03:00')) do
        expect { 1.day.ago }.not_to raise_error
      end
    end

    it 'Time.zone.parse should not throw exception' do
      expect { Time.zone.parse('26.10.2014 1:30:00') }.not_to raise_error
    end
  end
end
