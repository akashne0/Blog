class Article < ApplicationRecord
	has_many :comments, dependent: :destroy
	belongs_to :user

	validates :title, presence: true, length: { minimum: 3, maximum: 50 }
	validates :body, presence: true, length: { minimum: 10, maximum: 300 }
	#for image upload
	has_one_attached :image, :dependent => :destroy
	
	acts_as_votable
end

