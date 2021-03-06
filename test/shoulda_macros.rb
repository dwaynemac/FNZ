def should_have_attached_file(attachment)
  klass = self.name.gsub(/Test$/, '').constantize

  context "To support a paperclip attachment named #{attachment}, #{klass}" do
    should_have_db_column("#{attachment}_file_name",    :type => :string)
    should_have_db_column("#{attachment}_content_type", :type => :string)
    should_have_db_column("#{attachment}_file_size",    :type => :integer)
  end

  should "have a paperclip attachment named ##{attachment}" do
    assert klass.new.respond_to?(attachment.to_sym),
           "@#{klass.name.underscore} doesn't have a paperclip field named #{attachment}"
    assert_equal Paperclip::Attachment, klass.new.send(attachment.to_sym).class
  end
end