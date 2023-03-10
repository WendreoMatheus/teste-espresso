# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Otps::UserEnables', type: :feature) do
  it 'When OTP two-factor is not already enabled' do
    otp_secret = User.generate_otp_secret
    allow(User).to(receive(:generate_otp_secret).and_return(otp_secret))

    user = create(:user)
    login_as(user)

    visit edit_user_registration_path

    expect(page).to(have_content('Two factor authentication is NOT enabled.'))
    expect(page).to(have_link('Enable Two Factor Authentication'))

    click_link('Enable Two Factor Authentication')
    user.reload

    fill_in 'Code', with: user.otp(otp_secret).at(Time.zone.now)
    fill_in 'Enter your current password', with: 'letmein'
    click_button 'Confirm and Enable Two Factor'

    user.reload
    expect(page).to(have_content('Keep these backup codes safe in case you lose access to your authenticator app:'))

    click_link('Return to account settings')
    expect(page).to(have_content('2FA is enabled.'))
    expect(page).to(have_link('Disable Two Factor Authentication'))
  end
end
