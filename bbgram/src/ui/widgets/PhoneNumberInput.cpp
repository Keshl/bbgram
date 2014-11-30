#include "PhoneNumberInput.h"

#include <bb/cascades/Application>
#include <bb/cascades/Container>
#include <bb/cascades/DropDown>
#include <bb/cascades/StackLayout>
#include <bb/cascades/QmlDocument>

#include <bb/data/XmlDataAccess>

using namespace bb::cascades;
using namespace bb::data;

PhoneNumberInput::PhoneNumberInput()
{
    Container* container = Container::create();
    m_countryName = TextField::create();
    m_countryName->setHintText("Choose a country");
    m_countryName->setClearButtonVisible(false);
    m_countryName->setInputMode(TextFieldInputMode::Custom);
    m_countryName->input()->setFlags(TextInputFlag::VirtualKeyboardOff);
    container->add(m_countryName);

    Container* panel = Container::create();
    panel->setLayout(StackLayout::create().orientation(LayoutOrientation::LeftToRight));
    panel->setTopMargin(50);

    m_countryCode = TextField::create();
    m_countryCode->setInputMode(TextFieldInputMode::PhoneNumber);
    m_countryCode->setMaxWidth(150);
    m_countryCode->setText("+7");
    panel->add(m_countryCode);

    m_phoneNumber = TextField::create();
    m_phoneNumber->setInputMode(TextFieldInputMode::PhoneNumber);
    panel->add(m_phoneNumber);

    container->add(panel);

    setRoot(container);

    QObject::connect(m_countryName, SIGNAL(focusedChanged(bool)), this, SLOT(onCountryFocusChanged(bool)));

    m_dataModel = new GroupDataModel(this);
    m_dataModel->setSortingKeys(QStringList() << "name");
    m_dataModel->setGrouping(ItemGrouping::ByFirstChar);

    XmlDataAccess xda;
    QVariant list = xda.load(QDir::currentPath() +
                             "/app/native/assets/dm_countries.xml",
                             "/countries/country");
    m_countriesList = list.value<QVariantList>();
    m_dataModel->insertList(m_countriesList);
    emit dataModelChanged();
}

PhoneNumberInput::~PhoneNumberInput()
{
}

GroupDataModel* PhoneNumberInput::dataModel() const
{
    return m_dataModel;
}

void PhoneNumberInput::setFilter(const QString& filter)
{
    m_dataModel->clear();
    if (filter.isEmpty())
        m_dataModel->insertList(m_countriesList);
    else
    {
        QVariantList filteredList;
        for(QVariantList::const_iterator it = m_countriesList.begin(); it != m_countriesList.end(); ++it)
        {
            QMap<QString, QVariant> country = it->toMap();
            if(country["name"].toString().startsWith(filter, Qt::CaseInsensitive))
                filteredList.append(*it);
        };
        m_dataModel->insertList(filteredList);
    }
}

void PhoneNumberInput::setCountry(const QString& name, const QString& code)
{
    m_countryName->setText(name);
    m_countryCode->setText("+" + code);

    NavigationPane* navigationPane = static_cast<NavigationPane*>(Application::instance()->scene());
    if (navigationPane)
       navigationPane->pop();
}

QString PhoneNumberInput::phone() const
{
    return m_countryCode->text() + m_phoneNumber->text();
}

void PhoneNumberInput::onCountryFocusChanged(bool focused)
{
    if (focused)
    {
        NavigationPane* navigationPane = static_cast<NavigationPane*>(Application::instance()->scene());
        if (navigationPane)
        {
            QmlDocument* qml = QmlDocument::create("asset:///ui/pages/CountrySelect.qml");
            Page* page = qml->createRootObject<Page>();

            qml->setContextProperty("_phoneNumberInput", this);

            navigationPane->push(page);
        }
    }
}