class AppFactory

    def self.create(resource_class)
        resource_class == Candidate ? create_candidate : create_admin
    end

    def self.create_admin(options={})
        Admin.new(options)
    end

    def self.create_candidate
        candidate = Candidate.new
        candidate.build_address
        candidate
    end

end
