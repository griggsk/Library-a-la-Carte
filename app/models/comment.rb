class Comment < ActiveRecord::Base
  belongs_to :comment_resource

  validates_presence_of :body, :message => "is required"
  validates_format_of :author_email, :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?$/i
  validate :is_clean?

BAD_WORDS      = (IO.readlines RAILS_ROOT + '/lib/words.txt').each { |w| w.chop! }.freeze
  def is_clean?
    BAD_WORDS.each do |line|
      self.body.split.each do |word|
        if word.downcase == line.strip.downcase
          errors.add(:body, "Comment included an innapropriate word") 
          return
        end
      end
    end
  end
end
