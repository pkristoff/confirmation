module Event
  module Route
    UPLOAD_SPONSOR_COVENANT = :upload_sponsor_covenant
    PICK_CONFIRMATION_NAME = :pick_confirmation_name
    UPLOAD_BAPTISMAL_CERTIFICATE = :upload_baptismal_certificate
    BAPTISMAL_CERTIFICATE_UPDATE = :baptismal_certificate_update
    SPONSOR_COVENANT_UPDATE = :sponsor_covenant_update
    PICK_CONFIRMATION_NAME_UPDATE = :pick_confirmation_name_update

    UPDATE_MAPPING = {
        pick_confirmation_name: PICK_CONFIRMATION_NAME_UPDATE,
        baptismal_certificate_update: BAPTISMAL_CERTIFICATE_UPDATE,
        upload_sponsor_covenant: SPONSOR_COVENANT_UPDATE,
    }
  end
  module Document

    MAPPING = {
        covenant: '4. Candidate Covenant Form.pdf', # complete
        baptismal_certificate: '6. Baptismal Certificate.pdf', # complete
        sponsor_covenant: '7. Sponsor Covenant & Eligibility.pdf', # complete
        conversation_sponsor_candidate: '8. Conversation between Sponsor & Candidate.pdf',
        ministry_awareness: '9. Christian Ministry Awareness.pdf',
        confirmation_name: '10. Choosing a Confirmation Name.pdf' # complete
    }
  end
end