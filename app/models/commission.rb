class Commission < ApplicationRecord
  belongs_to :sale
  belongs_to :agent, class_name: "User", foreign_key: :agent_id
end
