class UserInfo < ApplicationRecord
    belongs_to :user #, inverse_of: :user_infos
end
