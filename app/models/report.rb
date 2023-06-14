class Report < ApplicationRecord
    belongs_to :reported_by, class_name: 'User'
    belongs_to :event, foreign_key: 'reported_id'

  enum status:{
    reported: 1,
    approved: 2,
    suspended: 3,
  }
  
end
