# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingSerializer do
      subject do
        described_class.new(meeting)
      end

      let!(:meeting) { create(:meeting, :published, contributions_count: 5, attendees_count: 10, attending_organizations: "Some organization") }
      let!(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: component.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { meeting.component }

      let(:accountability_component) do
        create(:component, manifest_name: :accountability, participatory_space: meeting.component.participatory_space)
      end
      let(:results) { create_list(:result, 2, component: accountability_component) }
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 2, component: proposal_component) }

      before do
        meeting.update!(taxonomies:)
        meeting.link_resources(proposals, "proposals_from_meeting")
        meeting.link_resources(results, "meetings_through_proposals")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: meeting.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies].length).to eq(2)
          expect(serialized[:taxonomies][:id]).to match_array(taxonomies.map(&:id))
          expect(serialized[:taxonomies][:name]).to match_array(taxonomies.map(&:name))
        end

        it "serializes the title" do
          expect(serialized).to include(title: meeting.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: meeting.description)
        end

        it "serializes the start time" do
          expect(serialized).to include(start_time: meeting.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include(end_time: meeting.end_time)
        end

        it "serializes the amount of attendees" do
          expect(serialized).to include(attendees: meeting.attendees_count)
        end

        it "serializes the amount of contributions" do
          expect(serialized).to include(contributions: meeting.contributions_count)
        end

        it "serializes the attending organizations" do
          expect(serialized).to include(organizations: meeting.attending_organizations)
        end

        it "serializes the address" do
          expect(serialized).to include(address: meeting.address)
        end

        it "serializes the location" do
          expect(serialized).to include(location: meeting.location)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: meeting.comments_count)
        end

        it "serializes the amount of followers" do
          expect(serialized).to include(followers: meeting.followers.count)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", meeting.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: meeting.component.id)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: meeting.reference)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(attachments: meeting.attachments.count)
        end

        it "serializes related proposals" do
          expect(serialized[:related_proposals].length).to eq(2)
          expect(serialized[:related_proposals].first).to match(%r{http.*/proposals})
        end

        it "serializes related results" do
          expect(serialized[:related_results].length).to eq(2)
          expect(serialized[:related_results].first).to match(%r{http.*/results})
        end

        it "serialized the published column" do
          expect(serialized).to include(published: meeting.published?)
        end
      end
    end
  end
end
