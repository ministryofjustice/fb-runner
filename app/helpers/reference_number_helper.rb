module ReferenceNumberHelper
  # rubocop :disable Style/MutableConstant
  RANDOM_SOURCE_SET_1 = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
  # rubocop :enable Style/MutableConstant
  RANDOM_SOURCE_SET_2 = '23456789'.freeze
  RANDOM_SOURCE_UNION = RANDOM_SOURCE_SET_1.concat(RANDOM_SOURCE_SET_2)

  def generate_reference_number
    s = StringIO.new
    10.times do |i|
      s << if i % 4 == 2
             RANDOM_SOURCE_SET_2[SecureRandom.rand(RANDOM_SOURCE_SET_2.length)]
           else
             RANDOM_SOURCE_UNION[SecureRandom.rand(RANDOM_SOURCE_UNION.length)]
           end
      if [2, 6].include?(i)
        s << '-'
      end
    end
    s.string
  end
end
