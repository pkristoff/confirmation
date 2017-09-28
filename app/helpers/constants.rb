module Event
  module Other
    PARENT_INFORMATION_MEETING = :parent_meeting
    ATTEND_RETREAT = :retreat_weekend
    CANDIDATE_COVENANT_AGREEMENT = :candidate_covenant_agreement
    CANDIDATE_INFORMATION_SHEET = :candidate_information_sheet
    SPONSOR_AND_CANDIDATE_CONVERSATION = :sponsor_agreement
  end
  module Route
    BAPTISMAL_CERTIFICATE = :baptismal_certificate
    BAPTISMAL_CERTIFICATE_UPDATE = :baptismal_certificate_update
    CHRISTIAN_MINISTRY = :christian_ministry
    CHRISTIAN_MINISTRY_UPDATE = :christian_ministry_update
    CONFIRMATION_NAME = :confirmation_name
    CONFIRMATION_NAME_UPDATE = :confirmation_name_update
    RETREAT_VERIFICATION = :retreat_verification
    RETREAT_VERIFICATION_UPDATE = :retreat_verification_update
    SPONSOR_COVENANT = :sponsor_covenant
    SPONSOR_COVENANT_UPDATE = :sponsor_covenant_update

    UPDATE_MAPPING = {
        baptismal_certificate_update: BAPTISMAL_CERTIFICATE_UPDATE,
        christian_ministry: CHRISTIAN_MINISTRY_UPDATE,
        confirmation_name: CONFIRMATION_NAME_UPDATE,
        retreat_verification: RETREAT_VERIFICATION,
        sponsor_covenant: SPONSOR_COVENANT_UPDATE
    }
  end
  module Document

    BAPTISMAL_CERTIFICATE = Event::Route::BAPTISMAL_CERTIFICATE
    CANDIDATE_CHECKLIST = :candidate_checklist
    CANDIDATE_COVENANT = :candidate_covenant
    CHRISTIAN_MINISTRY = Event::Route::CHRISTIAN_MINISTRY
    CONFIRMATION_NAME = Event::Route::CONFIRMATION_NAME
    CONVERSATION_SPONSOR_CANDIDATE = :conversation_sponsor_candidate
    RETREAT_VERIFICATION = Event::Route::RETREAT_VERIFICATION
    SPONSOR_COVENANT = Event::Route::SPONSOR_COVENANT

    MAPPING = {
        candidate_checklist: '2. Check List.pdf', # complete
        candidate_covenant: '4. Candidate Covenant Form.pdf', # complete
        information_sheet: '5. Information Sheet.pdf', # complete
        baptismal_certificate: '6. Baptismal Certificate.pdf', # complete
        sponsor_covenant: '7. Sponsor Covenant & Eligibility.pdf', # complete
        conversation_sponsor_candidate: '7. Sponsor Covenant & Eligibility.pdf',
        christian_ministry: '8. Christian Ministry Awareness.pdf',
        confirmation_name: '9. Choosing a Confirmation Name.pdf', # complete
        retreat_verification: '10. Retreat Verification.pdf' # complete
    }
  end
end
module SideBar
  TRUNCATELENGTH = 20
end