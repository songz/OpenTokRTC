class Client < ActiveRecord::Base
  attr_accessible :flag, :imgdata, :point, :room_id, :name

  belongs_to :room

  before_save :uploadImage

  def uploadImage
    filePath = "/clientImages/#{Time.now.to_f.to_s}.png"
    AWS::S3::S3Object.store( filePath, Base64.decode64(self.imgdata) , S3Bucket, :access => :public_read )
    self.imgdata = S3URL+filePath
  end
end
