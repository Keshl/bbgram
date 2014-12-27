#include "GroupChat.h"
#include "../utils/Colorizer.h"
#include "../Storage.h"

using namespace bb::cascades;

GroupChat::GroupChat(int id)
    : Peer(TGL_PEER_CHAT, id), m_adminId(0)
{
    m_members = new GroupDataModel();
    m_members->setParent(this);
    m_members->setSortingKeys(QStringList() << "firstName");
    m_members->setGrouping(ItemGrouping::None);
}

GroupChat::~GroupChat()
{
}

void GroupChat::load(const QVariantMap& map)
{
    Peer::load(map);

    QVariantMap::const_iterator it;

    it = map.find("title");
    if (it != map.end())
        m_title = it.value().toString();
    emit titleChanged();
    it = map.find("adminId");
    if (it != map.end())
        m_adminId = it.value().toInt();

    //map.insert("members", ??);
    //map.insert("invites", ??);
}

void GroupChat::save(QVariantMap& map) const
{
    Peer::save(map);

    map.insert("title", m_title);
    map.insert("adminId", m_adminId);
    //map.insert("members", ??);
    //map.insert("invites", ??);
}

QString GroupChat::title() const
{
    return m_title;
}

void GroupChat::setTitle(const QString& title)
{
    m_title = title;
    emit titleChanged();
}

QString GroupChat::status() const
{
    Message* message = lastMessage();
    if (message)
        return "<p>" + message->text() + "</p>";
    return "";
}

int GroupChat::getAdmin() const
{
    return m_adminId;
}

void GroupChat::setAdmin(int adminId)
{
    m_adminId = adminId;

    emit adminChanged();
}

void GroupChat::addMember(User* newMember, int inviterId)
{
    m_members->insert(newMember);
    m_invites.insert(newMember->id(), inviterId);

    emit membersChanged();
}

void GroupChat::deleteMember(User* member)
{
    m_members->remove(member);
    m_invites.remove(member->id());

    emit membersChanged();
}

void GroupChat::setMembers(const tgl_chat_user* members, int count)
{
    m_members->clear();
    m_invites.clear();

    for (int i = 0; i < count; i++)
    {
        User* member = (User*)Storage::instance()->getPeer(TGL_PEER_USER, members[i].user_id);
        m_members->insert(member);
        m_invites.insert(members[i].user_id, members[i].inviter_id);
    }

    emit membersChanged();
}

bb::cascades::DataModel* GroupChat::members() const
{
    return m_members;
}

bool GroupChat::canDeleteUser(User* self, User* target) const
{
    if (self->id() == target->id() || target->id() == m_adminId)
        return false;

    if (self->id() == m_adminId)
        return true;

    int selfId = self->id();
    int targetId = target->id();

    QMap<int, int>::const_iterator it = m_invites.find(targetId);
    if (it != m_invites.end())
        if (it.value() == selfId)
            return true;

    return false;
}
