# schema that defines LA data model with EdgeDB
module default {
  # main and only user of the tool
  type User extending WithCreatedAt {
    # unique email
    required email: str {
      constraint exclusive;
    };
    # unique username
    username: str {
      constraint exclusive;
    };
    constraint username on str_trim(str_lower(.username));
    # custom display name user can choose for themselves similar to X/GitHub
    displayName: str;
    # cloudflare R2 url with image
    profileImage: str;
    # topics user wants to learn
    multi topicsToLearn: GlobalTopic;
    # topics user is learning
    multi topicsLearning: GlobalTopic;
    # topics user learned
    multi topicsLearned: GlobalTopic;
    # total number of topics user is tracking
    property topicsTracked := count(.topicsToLearn) + count(.topicsLearning) + count(.topicsLearned);
    # links user wants to complete
    multi linksToComplete: PersonalLink;
    # links user is currently trying to complete
    multi linksInProgress: PersonalLink;
    # links user has completed
    multi linksCompleted: PersonalLink;
    # links user has liked
    multi linksLiked: PersonalLink;
    # total number of links user is interacting with
    # property linksTracked := count(.linksBookmarked) + count(.linksInProgress) + count(.linksCompleted) + count(.linksLiked);
    # date until user has paid membership for
    memberUntil: datetime;
    # paid monthly or yearly
    stripePlan: str;
    # after stripe payment succeeds, you get back subscription object id (can be used to cancel subscription)
    stripeSubscriptionObjectId: str;
    # whether user has stopped subscription and won't be be charged again
    subscriptionStopped: bool;
  }
  # unique links that are defined by their unique url (essentially a link with metadata)
  type GlobalLink extending WithCreatedAt {
    # unique url of the link (without protocol, like http://)
    required url: str {
      constraint exclusive;
    };
    # http / https / ..
    required protocol: str {
      default := "https"
    }
    # true = link was verified, valid URL, good metadata was added etc.
    required verified: bool {
      default := false;
    }
    # true = link is available for all to see/search. false = link is private
    required public: bool {
      default := false;
    }
    # title as grabbed from url
    urlTitle: str;
    # custom 'prettier/more-accurate' title as set by AI/community
    title: str;
    # link description, set by AI/community
    description: str;
    # optionally have a main topic that the link belongs to
    link mainTopic: GlobalTopic;
    # year in which link was created
    year: int16;
  }
  # PersonalLink exists on top of GlobalLink
  # User(s) can interact with PersonalLink by adding notes, marking as completed etc.
  type PersonalLink extending WithCreatedAt {
    # each PersonalLink has underlying GlobalLink
    required link globalLink: GlobalLink {
      constraint exclusive;
    };
    # custom title for link set by User
    title: str;
    # custom description for link set by User
    description: str;
    # custom description for link set by User
    note: str;
    # custom year for link set by User
    year: int16;
    # custom main topic for link set by User
    link mainTopic: GlobalTopic;
  }
  # GlobalTopic is a topic that is available to all users
  # It has name, related links, study guide, similar topics etc.
  type GlobalTopic extending WithCreatedAt {
    # url friendly unique name of topic. i.e. 'physics' or 'linear-algebra'
    # lowercase + dash separate words (TODO: enforce somehow?)
    required name: str {
      constraint exclusive;
    };
    # pretty version of `name`, properly capitalised, etc. (i.e. Physics)
    required prettyName: str;
    # true = topic was verified (reviewed by LA and approved to be shown on LA)
    required verified: bool {
      default := false;
    }
    # true = topic is available to anyone to see
    required public: bool {
      default := false;
    };
    # there is one global guide attached to each global topic
    latestGlobalGuide: GlobalGuide;
  }
  # GlobalGuide has sections of various type
  type GlobalGuide extending WithCreatedAt {
    # guide is split by sections
    multi sections: GlobalGuideSection {
      on target delete allow;
    }
  }
  # each GlobalGuideSection is part of some GlobalGuide
  type GlobalGuideSection extending WithCreatedAt {
    # title of section
    required title: str;
    # list of links in a section
    multi links: GlobalLink {
      order: int16;
    };
  }
  # attaches `created_at` field to objects that extend it
  # https://docs.edgedb.com/database/datamodel/objects#abstract-types
  abstract type WithCreatedAt {
    required created_at: datetime {
      readonly := true;
      default := datetime_of_statement();
    }
  }
}

