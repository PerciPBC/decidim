# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::CreateProject do
    subject { described_class.new(form) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:component, manifest_name: :budgets, participatory_space: participatory_process) }
    let(:budget) { create(:budget, component: current_component) }
    let(:uploaded_photos) { [] }
    let(:photos) { [] }
    let(:address) { nil }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: participatory_process)
    end
    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end
    let(:form) do
      double(
        invalid?: invalid,
        current_component:,
        current_user:,
        title: { en: "title" },
        description: { en: "description" },
        budget_amount: 10_000_000,
        address:,
        latitude:,
        longitude:,
        taxonomizations:,
        proposal_ids: proposals.map(&:id),
        photos:,
        add_photos: uploaded_photos,
        budget:
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:project) { Project.last }

      it "creates the project" do
        expect { subject.call }.to change(Project, :count).by(1)
      end

      it "sets the taxonomies" do
        subject.call
        expect(project.taxonomizations).to match_array(taxonomizations)
      end

      context "when no taxonomizations are set" do
        let(:taxonomizations) { [] }

        it "taxonomizations are empty" do
          subject.call

          expect(project.taxonomizations).to be_empty
        end
      end

      it "sets the budget resource" do
        subject.call
        expect(project.budget).to eq budget
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Budgets::Project,
            current_user,
            hash_including(:taxonomizations, :budget, :title, :description, :budget_amount),
            visibility: "all"
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when geocoding is enabled" do
        let(:current_component) { create(:budgets_component, :with_geocoding_enabled, participatory_space: participatory_process) }

        context "when the address is present" do
          let(:address) { "Some address" }

          before do
            stub_geocoding(address, [latitude, longitude])
          end

          it "sets the latitude and longitude" do
            subject.call
            project = Decidim::Budgets::Project.last

            expect(project.latitude).to eq(latitude)
            expect(project.longitude).to eq(longitude)
          end
        end
      end

      it "links proposals" do
        subject.call
        linked_proposals = project.linked_resources(:proposals, "included_proposals")
        expect(linked_proposals).to match_array(proposals)
      end

      it_behaves_like "admin creates resource gallery" do
        let(:command) { described_class.new(form) }
        let(:resource_class) { Decidim::Budgets::Project }
      end
    end
  end
end
