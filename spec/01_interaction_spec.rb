describe "User accounts" do
    describe "Sign up & Sign out" do
        it "a user can sign up" do
            visit('/signup')
            fill_in("username", :with => "lorem")
            fill_in("email", :with => "test@test.com")
            fill_in("user[password]", :with => "Password1!")
            fill_in("user[password_confirmation]", :with => "Password1!")
            click_button("Signup")
            expect(page).to have_content("Successfully logged in as lorem")
            click_link('Log out')
            expect(page).to have_content("You've successfully logged out")
        end
    end

    describe "Sign in" do
        before(:each) do
            visit('/login')
        end

        after(:each) do
            click_link('Log out')
        end
        
        it "a user can sign in with their username" do
            fill_in("username_or_email", :with => "lorem")
            fill_in("password", :with => "Password1!")
            click_button("Login")
            expect(page).to have_content("Successfully logged in as lorem")
        end

        it "a user can sign in with their email" do
            fill_in("username_or_email", :with => "test@test.com")
            fill_in("password", :with => "Password1!")
            click_button("Login")
            expect(page).to have_content("Successfully logged in as lorem")
        end
    end
end